local levee = require("levee")
local _ = require("levee")._

local ellen = require("ellen")

local term = ellen.term()

local last = 0

local function main(h, ws, stream)
	local panes = {
		main = ellen.pane(1, 1, ws.col, ws.row - 1),
		status = ellen.pane(1, ws.row, ws.col, 1), }

	local editor = ellen.editor()

	while true do
		panes.main:render(term, editor.lines)
		panes.status:render(term, {("x:%03d y:%03d last:%03d%s"):format(
			editor.x, editor.y, last, editor.mode == 1 and "  -- INSERT --" or "")})
		term:move(editor:cursor())
		local err, ch = stream:recv()
		last = string.byte(ch)
		local mode = editor:press(ch)
		if mode == 0 then break end
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
