local levee = require("levee")
local _ = require("levee")._


local ellen = require("ellen")


io.stdout:setvbuf('no')  -- unbuffer stdout


local ESC = "\27"


local term = ellen.term()


local x = 1
local line = ellen.spans()


local modes = {
	function(ch)
		if ch == ESC then
			if x > 1 then
				x = x - 1
				term:move_left()
			end
			return 2
		end
		line:put(ch)
		io.write(ch)
		x = x + 1
		return 1
	end,

	function(ch)
		if ch == "0" then
			if x > 1 then
				term:move_left(x-1)
				x = 1
			end
		end
		if ch == "$" then
			if x < #line then
				term:move_right(#line - x)
				x = #line
			end
		end
		if ch == "h" then
			if x > 1 then
				x = x - 1
				term:move_left()
			end
		end
		if ch == "l" then
			if x < #line then
				x = x + 1
				term:move_right()
			end
		end
		if ch == "q" then return 0 end
		return 2
	end,
}


local function main()
	local err, size = _.term.winsize(1)
	print(_.repr(size))

	local h = levee.Hub()

	local err, reset, stream = ellen.raw(h)

	local mode = modes[1]

	while true do
		local err, ch = stream:recv()
		mode = modes[mode(ch)]
		if not mode then break end
	end

	reset()
	io.write("\n")
end


main()
