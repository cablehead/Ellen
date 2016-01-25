local levee = require("levee")
local _ = require("levee")._


local ellen = require("ellen")


io.stdout:setvbuf('no')  -- unbuffer stdout


local ESC = "\27"


local term = ellen.term()


local x = 0
local line = ellen.line()


local modes = {
	function(ch)
		if ch == ESC then
			return 2
		end

		line:put(x, ch)
		term:EL()
		io.write(line:tail(x))

		x = x + 1
		return 1
	end,

	function(ch)
		if ch == "0" then
			x = 1
		end
		if ch == "$" then
			x = #line
		end
		if ch == "h" then
			x = x - 1
		end
		if ch == "l" then
			x = x + 1
		end
		if ch == "i" then x = x - 1 return 1 end
		if ch == "q" then return 0 end
		return 2
	end,
}


local function main()
	local err, size = _.term.winsize(1)
	print(_.repr(size))

	local h = levee.Hub()

	local err, reset, stream = ellen.raw(h)

	term:clear()

	local mode = 1

	while true do
		term:move(1, 2)
		term:EL()
		io.write(("mode: %d x: %d"):format(mode, x))
		term:move(mode == 1 and x + 1 or x, 1)
		local err, ch = stream:recv()
		mode = modes[mode](ch)
		if mode == 0 then break end
		if x < 0 then x = 0 end
		if x > #line then x = #line end
	end

	reset()
	term:move(1, 2)
	term:EL()
	print(line:tail(0))
end


main()
