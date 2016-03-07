local Pane_mt = {}
Pane_mt.__index = Pane_mt


function Pane_mt:render(term, lines)
	local h = 0
	while h < self.h do
		local line = lines[h + 1] or ""
		local compare = self.lines[h + 1] or ""
		if line.peek then line = line:peek(self.w) end
		if line ~= compare then
			term:move(self.x, self.y + h)
			term:EL(2)
			io.write(line)
		end
		self.lines[h + 1] = line
		h = h + 1
	end
end


return function(x, y, w, h)
	local self = setmetatable({}, Pane_mt)
	self.x = x
	self.y = y
	self.w = w
	self.h = h
	self.lines = {}
	return self
end
