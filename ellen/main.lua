local levee = require("levee")
local _ = require("levee")._


local ellen = require("ellen")


io.stdout:setvbuf('no')  -- unbuffer stdout


local ESC = "\27"


local term = ellen.term()


local modes = {
	function(ch)
		if ch == ESC then return 2 end
		io.write(ch)
		return 1
	end,

	function(ch)
		if ch == "h" then term:move_left() end
		if ch == "l" then term:move_right() end
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
