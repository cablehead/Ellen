local Line = require("ellen.line")
local k = require("ellen.keys")


local Editor_mt = {}
Editor_mt.__index = Editor_mt


function Editor_mt:mode_insert(ch)
	local line = self.lines[self.y]

	if ch == k.ESC then return self.mode_command end

	if ch == k.BS then
		if self.x < 1 then
			if self.y <= 1 then return end

			-- merge with previous line
			self.y = self.y - 1
			local prev = self.lines[self.y]
			self.x = #prev
			prev:splice(self.x, 0, line:peek())
			table.remove(self.lines, self.y + 1)
			return
		end

		self.x = self.x - 1
		line:splice(self.x, 1)
		return
	end

	if ch == k.ENT then
		local rest = line:splice(self.x)
		self.x = 0
		self.y = self.y + 1
		table.insert(self.lines, self.y, Line(rest))
		return
	end

	line:splice(self.x, 0, ch)
	self.x = self.x + 1
end


function Editor_mt:mode_command(ch)
	local line = self.lines[self.y]
	if ch == "0" then self.x = 1 end
	if ch == "$" then self.x = #line end
	if ch == "j" then self.y = self.y + 1 end
	if ch == "k" then self.y = self.y - 1 end
	if ch == "h" then self.x = self.x - 1 end
	if ch == "l" then self.x = self.x + 1 end
	if ch == "i" then self.x = self.x - 1; return self.mode_insert end
	if ch == "a" then return 1 end
	if ch == "A" then self.x = #line; return self.mode_insert end
	if ch == "q" then return 0 end
end


function Editor_mt:press(ch)
	local mode = self.mode(self, ch)
	if mode then self.mode = mode end
	if self.y < 1 then self.y = 1 end
	if self.y > #self.lines then self.y = #self.lines end
	local line = self.lines[self.y]
	if self.x < 0 then self.x = 0 end
	if self.x > #line then self.x = #line end
	return self.mode
end


function Editor_mt:cursor()
	return self.mode == self.mode_insert and self.x + 1 or self.x, self.y
end


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

	self.x = options.x or 0
	self.y = options.y or 1

	self.mode = self.mode_insert
	return self
end
