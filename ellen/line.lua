local ffi = require("ffi")

local _ = require("levee")._
local d = require("levee").d


local Line_mt = {}
Line_mt.__index = Line_mt


function Line_mt:__len()
	return self.len
end


function Line_mt:locate(x)
	local n = 1
	while true do
		local span = self.spans[n]
		if x <= #span then return n, x end
		n = n + 1
		x = x - #span
	end
end


function Line_mt:tail(x)
	local n, x = self:locate(x)
	local ret = {}
	table.insert(ret, ffi.string(self.spans[n].buf + x, self.spans[n].len - x))
	for i = n + 1, #self.spans do
		table.insert(ret, self.spans[i]:peek())
	end
	return table.concat(ret)
end


function Line_mt:put(x, s)
	self.len = self.len + #s

	local n, x = self:locate(x)

	local span = self.spans[n]

	if x < #span then
		-- split span
		local buf, len = span:value()
		local tail = len - x

		local tgt = d.Buffer(n)
		C.memcpy(tgt.buf, buf + x, tail)
		tgt:bump(tail)
		table.insert(self.spans, n + 1, tgt)

		span.len = span.len - tail
	end

	span:push(s)
end


return function()
	local self = setmetatable({}, Line_mt)

	self.len = 0

	self.spans = {
		d.Buffer()
	}

	return self
end
