local ffi = require("ffi")

local _ = require("levee")._
local d = require("levee").d


local Line_mt = {}
Line_mt.__index = Line_mt


function Line_mt:__len()
	return #self.buf
end


function Line_mt:peek(len)
	return self.buf:peek(len)
end


function Line_mt:splice(idx, x, s)
	local b = self.buf
	assert(idx <= #b)

	x = x or #b - idx

	local start = b.buf + b.off + idx

	local del = ""
	if x > 0 then
		del = ffi.string(start, x)
	end

	local keep
	if #b > idx + x then
		keep = ffi.string(start + x, #b - idx - x)
	end

	b.len = idx
	if s then b:push(s) end
	if keep then b:push(keep) end
	return del
end


return function(s)
	local self = setmetatable({}, Line_mt)
	self.buf = d.Buffer()
	if s and #s > 0 then self.buf:push(s) end
	return self
end
