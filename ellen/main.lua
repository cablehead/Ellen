local levee = require("levee")
local _ = require("levee")._


local ellen = require("ellen")


io.stdout:setvbuf('no')  -- unbuffer stdout


local function main()
	local err, size = _.term.winsize(1)
	print(_.repr(size))

	local h = levee.Hub()

	local err, reset, stream = ellen.raw(h)

	while true do
		local err, ch = stream:recv()
		io.write(ch)
		if ch == "q" then break end
	end

	reset()
	io.write("\n")
end


main()
