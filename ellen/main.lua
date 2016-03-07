local levee = require("levee")
local _ = require("levee")._

local ellen = require("ellen")

local ESC = "\27"
local ENT = "\13"
local BS = "\127"

local term = ellen.term()

local x = 0
local y = 1

local last = 0


local lines = {
	ellen.line(), }




local modes = {
	function(ch)
		local line = lines[y]

		if ch == ESC then return 2 end

		if ch == BS then
			x = x - 1
			line:splice(x, 1)
			return 1
		end

		if ch == ENT then
			local rest = line:splice(x)
			x = 0
			y = y + 1
			table.insert(lines, y, ellen.line(rest))
			return 1
		end

		last = string.byte(ch)

		line:splice(x, 0, ch)
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
		if ch == "i" then x = x - 1; return 1 end
		if ch == "a" then return 1 end
		if ch == "A" then x = #line; return 1 end
		if ch == "q" then return 0 end
		return 2
	end,
}


local function main(h, ws, stream)
	local panes = {
		main = ellen.pane(1, 1, ws.col, ws.row - 1),
		status = ellen.pane(1, ws.row, ws.col, 1), }
	local mode = 1
	while true do
		panes.main:render(term, lines)
		panes.status:render(
			term, {("mode:%s x:%s y:%s last:%s"):format(mode, x, y, last)})
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



---
io.stdout:setvbuf('no')  -- unbuffer stdout

local h = levee.Hub()

local err, reset, stream = ellen.raw(h)
assert(not err)

local err, ws = _.term.winsize(1)
term:buf_alt()

local status, rc = xpcall(
	function() return main(h, ws, stream) end,
	function(err) return debug.traceback() .. "\n\n" .. err end)

reset()
term:buf_norm()


if status then os.exit(rc) end

print(rc)
os.exit(1)
