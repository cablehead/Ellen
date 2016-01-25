local ffi = require("ffi")
local C = ffi.C


local levee = require("levee")
local _ = require("levee")._
local d = require("levee").d


local function region(x, y, w, h)
	local patt = '\27[%d;%d;%d;%dr'
	-- return patt:format(y, y+h, x, x+w)
  return '\27[4;7r'
end


io.stdin:setvbuf('no')  -- unbuffer stdin
io.stdout:setvbuf('no')  -- unbuffer stdout


local function main()
	local h = levee.Hub()

	io.write(clear)
  io.write('\27[r')

	do return end

	io.write(region(5, 5, 10, 10))
	io.write(movcu:format(0, 0))

	while true do
		io.write(".")
		h:sleep(30)
	end
end


local Term_mt = {}
Term_mt.__index = Term_mt


function Term_mt:send(...)
	self:write("\27["..table.concat({...}))
end


function Term_mt:write(s)
	io.write(s)
end


function Term_mt:EL(n)
	-- n == 0; from cursor to end of line
	-- n == 1; from cursor to beginning of line
	-- n == 2; entire line
	self:send(n or 0, "K")
end


function Term_mt:move(x, y)
	self:send(y, ";", x, "H")
end


function Term_mt:move_up(n)
	self:send(n or 0, "A")
end


function Term_mt:move_down(n)
	self:send(n or 0, "B")
end

function Term_mt:move_right(n)
	self:send(n or 0, "C")
end

function Term_mt:move_left(n)
	self:send(n or 0, "D")
end


function Term_mt:clear()
	self:send("2J")
end


local function Term(no)
	local self = setmetatable({}, Term_mt)
	self.no = no or 1
	return self
end


local function tty_raw(no, o)
	local raw = ffi.new("struct termios")

	-- input modes - clear indicated ones giving: no break, no CR to NL, no
	-- parity check, no strip char, no start/stop output (sic) control 
	raw.c_iflag = bit.band(
		o.c_iflag,
		bit.bnot(bit.bor(C.BRKINT, C.ICRNL, C.INPCK, C.ISTRIP, C.IXON)))

	-- output modes - clear giving: no post processing such as NL to CR+NL
	raw.c_oflag = bit.band(o.c_oflag, bit.bnot(C.OPOST))

	-- control modes - set 8 bit chars
	raw.c_cflag = bit.bor(o.c_cflag, C.CS8)

	-- local modes - clear giving: echoing off, canonical off (no erase with
	-- backspace, ^U,...),  no extended functions, no signal chars (^Z,^C)
	raw.c_lflag = bit.band(
		o.c_lflag,
		bit.bnot(bit.bor(C.ECHO, C.ICANON, C.IEXTEN, C.ISIG)))

	-- control chars - set return condition: min number of bytes and timer
	-- after 5 bytes or .8 seconds after first byte seen
	-- raw.c_cc[C.VMIN] = 5; raw.c_cc[C.VTIME] = 8;
	-- raw.c_cc[C.VMIN] = 0; raw.c_cc[C.VTIME] = 0; -- immediate - anything
	-- raw.c_cc[C.VMIN] = 2; raw.c_cc[C.VTIME] = 0; -- after two bytes, no timer
	-- raw.c_cc[C.VMIN] = 0; raw.c_cc[C.VTIME] = 8; -- after a byte or .8 seconds

	-- put terminal in raw mode after flushing
	local rc = C.tcsetattr(no, C.TCSAFLUSH, raw)
	assert(rc >= 0)
end


local function main2()
	local term = Term()

	local h = levee.Hub()

	local buffer = {
		d.Buffer(),
		d.Buffer(),
	}

	buffer[1]:push("Hi there")
	buffer[2]:push("How are you?")

	term:clear()
	term:move(1, 1)

	for i, line in ipairs(buffer) do
		print(line:peek())
	end

	local ts = ffi.new("struct termios[1]")
	local rc = C.tcgetattr(0, ts)
	assert(rc >= 0)

	-- tty_raw(0, ts[0])
	local raw = ffi.new("struct termios[1]")
	local rc = C.tcgetattr(0, raw)
	assert(rc >= 0)
	C.cfmakeraw(raw)
	local rc = C.tcsetattr(0, C.TCSAFLUSH, raw[0])
	assert(rc >= 0)

	local stdin = h.io:r(0)
	local s = stdin:stream()

	while true do
		s:readin(1)
		local ch = s:take()
		--[[
		io.write("\27[2K")
		io.write(("\r%d: "):format(#ch))
		for x in ch:gmatch(".") do
			io.write(("%d"):format(string.byte(x)))
		 end
		 --]]
		if ch == "h" then term:move_left() end
		if ch == "j" then term:move_down() end
		if ch == "k" then term:move_up() end
		if ch == "l" then term:move_right() end
		if ch == "*" then io.write("\27[@*") end
		if ch == "D" then term:EL() end
		if ch == "q" then break end
	end

	-- reset
	local rc = C.tcsetattr(0, C.TCSAFLUSH, ts[0])
	assert(rc >= 0)

	print()

	do return end

	local err, size = _.term.winsize(1)
	print(_.repr(size))

	-- term:clear()

	do return end

	io.write(clear)
	io.write('\27[?25l')

	for i = 1, 20 do
		if i > 1 then
			io.write(movcu:format(i-1, 0))
			io.write("  ")
		end
		io.write(movcu:format(i, 0))
		io.write("hi")
		h:sleep(50)
	end

	io.write(movcu:format(30, 0))
	io.write('\27[?25h')
end

main2()
