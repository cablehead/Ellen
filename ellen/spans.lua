local _ = require("levee")._
local d = require("levee").d


local Spans_mt = {}
Spans_mt.__index = Spans_mt


function Spans_mt:__len()
	return self.len
end

function Spans_mt:put(s)
	self.len = self.len + #s

	local span = self.spans[self.n]
	if #span == self.x then
		self.x = self.x + #s
		span:push(s)
		return
	end

	local buf, len = span:value()
	local n = len - self.x

	local tgt = d.Buffer(n)
	C.memcpy(tgt.buf, buf + self.x, n)
	tgt:bump(n)

	span.len = span.len - n
	self.x = self.x + #s
	span:push(s)

	table.insert(self.spans, self.n + 1, tgt)
end


return function()
	local self = setmetatable({}, Spans_mt)

	self.len = 0
	self.n = 1
	self.x = 0

	self.spans = {
		d.Buffer()
	}

	return self
end
