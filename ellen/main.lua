local levee = require("levee")
local _ = require("levee")._

io.stdout:setvbuf('no')  -- unbuffer stdout

local ellen = require("ellen")

local ESC = "\27"

local term = ellen.term()

local x = 0
local y = 1


local lines = {
	ellen.line(), }


local modes = {
	function(ch)
		local line = lines[y]

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
		local line = lines[y]

		if ch == "0" then x = 1 end
		if ch == "$" then x = #line end
		if ch == "j" then y = y + 1 end
		if ch == "k" then y = y - 1 end
		if ch == "h" then x = x - 1 end
		if ch == "l" then x = x + 1 end
		if ch == "i" then x = x - 1 return 1 end
		if ch == "q" then return 0 end
		return 2
	end,
}


local function status(row, s, ...)
	term:move(1, row)
	term:EL()
	io.write(s:format(...))
end


local function main(h, ws, stream)
	local mode = 1
	while true do
		status(ws.row, "mode: %s x: %s y:%s", mode, x, y)
		term:move(mode == 1 and x + 1 or x, y)
		local err, ch = stream:recv()
		mode = modes[mode](ch)
		if mode == 0 then break end

		if y < 1 then y = 1 end
		if y > #lines then y = #lines end
		local line = lines[y]
		if x < 0 then x = 0 end
		if x > #line then x = #line end
	end
end


local h = levee.Hub()

local err, reset, stream = ellen.raw(h)
assert(not err)

local err, ws = _.term.winsize(1)
term:clear()

local status, rc = xpcall(
	function() return main(h, ws, stream) end,
	function(err) return debug.traceback() .. "\n\n" .. err end)

reset()
term:move(1, ws.row)
io.write("\n")

if status then os.exit(rc) end

print(rc)
os.exit(1)
