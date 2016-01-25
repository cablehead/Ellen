local ffi = require("ffi")
local C = ffi.C

local _ = require("levee._")


return function(h)
	local ts = ffi.new("struct termios[1]")
	local rc = C.tcgetattr(0, ts)
	assert(rc >= 0)

	local raw = ffi.new("struct termios[1]")
	local rc = C.tcgetattr(0, raw)
	assert(rc >= 0)

	C.cfmakeraw(raw)
	local rc = C.tcsetattr(0, C.TCSAFLUSH, raw[0])
	assert(rc >= 0)

	local sender, recver = h:pipe()

	h:spawn(function()
		_.fcntl_nonblock(0)
		local stdin = h.io:r(0)
		local s = stdin:stream()
		while true do
			s:readin(1)
			for i = 1, #s.buf do
				sender:send(ffi.string(s.buf.buf+(i-1), 1))
			end
			s:trim()
		end
	end)

	local function reset()
		local rc = C.tcsetattr(0, C.TCSAFLUSH, ts[0])
		assert(rc >= 0)
	end

	return nil, reset, recver
end
