local Line = require("ellen.line")
local k = require("ellen.keys")


local Editor_mt = {}
Editor_mt.__index = Editor_mt


function Editor_mt:mode_insert(ch)
	table.insert(self.last, ch)

	local line = self.lines[self.y]

	if ch == k.ESC then self.x = self.x - 1; return 2 end

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


function Editor_mt:mode_command(ch)
	if self.chord then return self:mode_chord(ch) end

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
		self.chord = "d"
	end
	if ch == "." then self:press(table.concat(self.last)) end
	if ch == "q" then return 0 end
end


function Editor_mt:mode_chord(ch)
	if self.chord == "d" and ch == "d" then
		table.remove(self.lines, self.y)
		self.last = {"d", "d"}
	else
		self.alert = ("bad chord: %s%s"):format(self.chord, ch)
	end
	self.chord = nil
end


function Editor_mt:press(...)
	for __, chain in ipairs({...}) do
		for ch in chain:gmatch(".") do
			self.alert = nil

			local mode = self.modes[self.mode](self, ch)

			if mode then
				if mode == 1 then self.last = {ch} end
				self.mode = mode
			end

			if self.y < 1 then self.y = 1 end
			if self.y > #self.lines then self.y = #self.lines end
			local line = self.lines[self.y]

			local max_x = self.mode == 1 and #line + 1 or #line
			if self.x > max_x then self.x = max_x end
			if self.x < 1 then self.x = 1 end
		end
	end
	return self.mode
end


function Editor_mt:cursor()
	return self.mode == 1 and self.x + 1 or self.x, self.y
end


Editor_mt.modes = {
	Editor_mt.mode_insert,
	Editor_mt.mode_command, }


return function(options)
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
	return self
end
