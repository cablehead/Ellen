local levee = require("levee")
local _ = require("levee")._

local ellen = require("ellen")

local last = 0

local function main(h, term, ws, stream)

	local fh = io.open("ellen/editor.lua")

	local lines = {}
	while true do
		local line = fh:read("*line")
		if not line then break end
		line = line:gsub("\t", "  ")
		table.insert(lines, line)
	end

	-- lines = {""}

	local editor = ellen.editor({lines=lines})

	local p1, div, p2 = unpack(ellen.layout.split(ws.col))

	for y = 1, ws.row-1 do
		term:move(div[1], y)
		term:write(ellen.layout.VR)
	end

	local panes = {
		main = ellen.pane(p2[1], 1, p2[2], ws.row - 1),
		status = ellen.pane(1, ws.row, ws.col, 1), }

	while true do
		if editor.y - panes.main.y_offset > panes.main.h then
			panes.main.y_offset = editor.y - panes.main.h
		end

		if editor.y <= panes.main.y_offset then
			panes.main.y_offset = editor.y - 1
		end

		panes.main:render(term, editor.lines)
		panes.status:render(term, {("x:%03d y:%03d y_off:%03d last:%03d%15s%s"):format(
			editor.x,
			editor.y,
			panes.main.y_offset,
			last,
			editor.mode == 1 and "  -- INSERT --" or "",
			editor.alert or "")})
		panes.main:move(term, editor.x, editor.y - panes.main.y_offset)
		local err, ch = stream:recv()
		last = string.byte(ch)
		local mode = editor:press(ch)
		if mode == 0 then break end
	end
end

---
-- io.stdout:setvbuf('no')  -- unbuffer stdout

local h = levee.Hub()

local term = ellen.term(h)

local err, reset, stream = ellen.raw(h)
assert(not err)

local err, ws = _.term.winsize(1)
term:buf_alt()

local status, rc = xpcall(
	function() return main(h, term, ws, stream) end,
	function(err) return debug.traceback() .. "\n\n" .. err end)

reset()
term:buf_norm()

if status then os.exit(rc) end

print(rc)
os.exit(1)
