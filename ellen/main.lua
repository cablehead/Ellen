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
			term:EL(2)
			term:move(1, y)
			io.write(line:peek())
			return 1
		end

		if ch == ENT then
			x = 0
			y = y + 1
			table.insert(lines, y, ellen.line())
			-- TODO:
			-- split current line into new line
			-- redraw all subsequent lines, moved down one position
			return 1
		end

		last = string.byte(ch)

		line:splice(x, 0, ch)
		term:EL(2)
		term:move(1, y)
		io.write(line:peek())
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


local function status(row, s, ...)
	term:move(1, row)
	term:EL()
	io.write(s:format(...))
end


local function main(h, ws, stream)
	local lines = {}
	local longest = 0

	local fh = io.open("/Users/andy/tmp/banksy.txt")
	while true do
		local line = fh:read("*l")
		if not line then break end
		longest = math.max(longest, #line)
		table.insert(lines, ellen.line(line))
	end
	fh:close()

	ws.col = 34

	local function draw(offset_x, offset_y)
		for i = 1, ws.row - 1 do
			term:move(1, i)
			term:EL(2)
			io.write(lines[i+offset_y]:peek():sub(1+offset_x, ws.col+offset_x))
		end
	end

	local offset_x = 0
	local offset_y = 0

	local xdir = 1
	local ydir = 1

	local function dupdate(d, curr, max)
		if d == 1 then
			if curr == max then return -1 end
			-- if math.random() < curr / max then return -1 end
			return 1
		end
		if curr == 0 then return 1 end
		-- if math.random() > curr / max then return 1 end
		return -1
	end


	for __ = 0, 200 do
		draw(offset_x, offset_y)
		h:sleep(50)

		xdir = dupdate(xdir, offset_x, longest-ws.col)
		ydir = dupdate(ydir, offset_y, #lines - ws.row)

		offset_x = offset_x + xdir
		offset_y = offset_y + ydir
	end

	do return end
	local mode = 1
	while true do
		status(ws.row, "mode:%s x:%s y:%s last:%s", mode, x, y, last)
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
