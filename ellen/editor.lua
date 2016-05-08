local Line = require("ellen.line")
local k = require("ellen.keys")


local I_mt = {}
I_mt.__index = I_mt


function I_mt:__next_chain()
	self.idx = self.idx or 0
	self.idx = self.idx + 1
	local chain = self.chains[self.idx]
	if chain then
		return chain:gmatch(".")
	end
end


function I_mt:peek()
	if self.nxt then return nil, self.nxt end
	local err
	err, self.nxt = self:recv()
	return err, self.nxt
end


function I_mt:recv()
	if self.nxt then
		local ret = self.nxt
		self.nxt = nil
		return nil, ret
	end
	if not self.chain then return "fin" end
	local ch = self.chain()
	if ch then return nil, ch end
	self.chain = self:__next_chain()
	return self:recv()
end


function I_mt:__call()
	local err, ch = self:recv()
	if err then return end
	return ch
end


local function I(...)
	local self = setmetatable({}, I_mt)
	self.chains = {...}
	self.chain = self:__next_chain()
	return self
end


local Editor_mt = {}
Editor_mt.__index = Editor_mt


function Editor_mt:mode_insert(ch)
	table.insert(self.__edit, ch)

	local line = self.lines[self.y]

	if ch == k.ESC then
		self.x = self.x - 1
		self.last = table.concat(self.__edit)
		return 2
	end

	if ch == k.BS then
		if self.x <= 1 then
			if self.y <= 1 then return end

			-- merge with previous line
			self.y = self.y - 1
			local prev = self.lines[self.y]
			self.x = #prev + 1
			prev:splice(self.x, 0, line:peek())
			table.remove(self.lines, self.y + 1)
			return
		end

		self.x = self.x - 1
		line:splice(self.x, 1)
		return
	end

	if ch == k.TAB then
		line:splice(self.x, 0, "  ")
		self.x = self.x + 2
		return
	end

	if ch == k.ENT then
		local rest = line:splice(self.x)
		self.x = 1
		self.y = self.y + 1
		table.insert(self.lines, self.y, Line(rest))
		return
	end

	line:splice(self.x, 0, ch)
	self.x = self.x + 1
end


function Editor_mt:mode_command(ch, input)
	-- if self.chord then return self:mode_chord(ch) end

	local line = self.lines[self.y]

	if ch == "0" then self.x = 1 end
	if ch == "$" then self.x = #line end
	if ch == "j" then self.y = self.y + 1 end
	if ch == "k" then self.y = self.y - 1 end
	if ch == "h" then self.x = self.x - 1 end
	if ch == "l" then self.x = self.x + 1 end
	if ch == "G" then self.y = #self.lines end
	if ch == "i" then return 1 end
	if ch == "I" then self.x = 1; return 1 end
	if ch == "a" then self.x = self.x + 1; return 1 end
	if ch == "A" then self.x = #line + 1; return 1 end
	if ch == "o" then
		self.x = 1
		self.y = self.y + 1
		table.insert(self.lines, self.y, Line())
		return 1
	end
	if ch == "O" then
		self.x = 1
		table.insert(self.lines, self.y, Line())
		return 1
	end
	if ch == "d" then
		local s = ch
		local err, ch = input:recv()
		if err then return 0 end
		if ch == "d" then
			self.last = "dd"
			table.remove(self.lines, self.y)
			return
		end
		self.alert = ("bad chord: %s%s"):format(s, ch)
		return
	end
	if ch == "." then
		if not self.last then
			self.alert = "no last"
			return
		end
		self:__run(self.last)
	end
	if ch == "q" then return 0 end
end


function Editor_mt:__run(input)
	if type(input) == "string" then input = I(input) end
	for ch in input do
		self.alert = nil

		local mode = self.modes[self.mode](self, ch, input)

		if mode then
			if mode == 0 then break end
			if mode == 1 then self.__edit = {ch} end
			self.mode = mode
		end

		if self.y < 1 then self.y = 1 end
		if self.y > #self.lines then self.y = #self.lines end
		local line = self.lines[self.y]

		local max_x = self.mode == 1 and #line + 1 or #line
		if self.x > max_x then self.x = max_x end
		if self.x < 1 then self.x = 1 end

		if self.changes then self.changes:send(self.mode) end
	end
end


function Editor_mt:run(input)
	self:__run(input)
	if self.changes then self.changes:close() end
end


function Editor_mt:cursor()
	return self.mode == 1 and self.x + 1 or self.x, self.y
end


Editor_mt.modes = {
	Editor_mt.mode_insert,
	Editor_mt.mode_command, }


return {
	Editor = function(options)
		local self = setmetatable({}, Editor_mt)

		options = options or {}

		if options.lines then
			self.lines = {}
			for __, s in ipairs(options.lines) do
				table.insert(self.lines, Line(s))
			end
		else
			self.lines = {Line(), }
		end

		self.x = options.x or 1
		self.y = options.y or 1
		self.mode = 2

		self.changes = options.changes
		return self
	end,

	I = I, }
