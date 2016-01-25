local _ = require("levee")._
local d = require("levee").d


local Line_mt = {}
Line_mt.__index = Line_mt


function Line_mt:__len()
	return self.len
end


function Line_mt:put(s)
	self.len = self.len + #s

	local span = self.spans[self.n]

	if self.x < #span then
		-- split span
		local buf, len = span:value()
		local n = len - self.x

		local tgt = d.Buffer(n)
		C.memcpy(tgt.buf, buf + self.x, n)
		tgt:bump(n)
		table.insert(self.spans, self.n + 1, tgt)

		span.len = span.len - n
	end

	self.x = self.x + #s
	span:push(s)
end


return function()
	local self = setmetatable({}, Line_mt)

	self.len = 0
	self.n = 1
	self.x = 0

	self.spans = {
		d.Buffer()
	}

	return self
end
