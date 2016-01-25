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
