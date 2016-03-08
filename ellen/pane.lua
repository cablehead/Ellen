local Pane_mt = {}
Pane_mt.__index = Pane_mt


package.path = package.path .. ";./lexers/?.lua"
local lexer = require("lexer")
local lua_lexer = lexer.load("lua")


--
-- colors

local txtblk='\27[0;30m' -- Black - Regular
local txtred='\27[0;31m' -- Red
local txtgrn='\27[0;32m' -- Green
local txtylw='\27[0;33m' -- Yellow
local txtblu='\27[0;34m' -- Blue
local txtpur='\27[0;35m' -- Purple
local txtcyn='\27[0;36m' -- Cyan
local txtwht='\27[0;37m' -- White
local bldblk='\27[1;30m' -- Black - Bold
local bldred='\27[1;31m' -- Red
local bldgrn='\27[1;32m' -- Green
local bldylw='\27[1;33m' -- Yellow
local bldblu='\27[1;34m' -- Blue
local bldpur='\27[1;35m' -- Purple
local bldcyn='\27[1;36m' -- Cyan
local bldwht='\27[1;37m' -- White
local unkblk='\27[4;30m' -- Black - Underline
local undred='\27[4;31m' -- Red
local undgrn='\27[4;32m' -- Green
local undylw='\27[4;33m' -- Yellow
local undblu='\27[4;34m' -- Blue
local undpur='\27[4;35m' -- Purple
local undcyn='\27[4;36m' -- Cyan
local undwht='\27[4;37m' -- White
local bakblk='\27[40m'   -- Black - Background
local bakred='\27[41m'   -- Red
local bakgrn='\27[42m'   -- Green
local bakylw='\27[43m'   -- Yellow
local bakblu='\27[44m'   -- Blue
local bakpur='\27[45m'   -- Purple
local bakcyn='\27[46m'   -- Cyan
local bakwht='\27[47m'   -- White
local txtrst='\27[0m'    -- Text Reset


function Pane_mt:highlight(term, lines)
	local parts = {}
	for __, line in ipairs(lines) do
		table.insert(parts, line:peek(self.w))
	end

	local text = table.concat(parts, "\n")
	local tokens = lua_lexer:lex(text)
	local itokens = (function()
		local i = -1
		return function()
			i = i + 2
			return tokens[i], tokens[i+1]
		end
	end)()

	local colors = {}
	colors.keyword = txtylw
	colors.comment = txtpur
	colors["function"] = txtblu
	colors.string = txtred

	local i = 0
	local token, nxt = nil, 1

	term:move(self.x, self.y)
	local h = 0
	local len = 0
	for c in text:gmatch(".") do
		i = i + 1
		if i == nxt then
			io.write(txtrst)
			token, nxt = itokens()
			if colors[token] then io.write(colors[token]) end
		end

		if c == "\n" then
			h = h + 1
			if (self.lengths[h] or 0) > len then term:EL() end
			self.lengths[h] = len
			len = 0
			term:move(self.x, self.y + h)
		else
			len = len + 1
			io.write(c)
		end
	end

	h = h + 1
	self.lengths[h] = len
	term:EL()
	io.write(txtrst)

	for i = h, #self.lengths do
		if self.lengths[i] > 0 then
			term:move(self.x, self.y + i)
			term:EL()
		end
	end
end


function Pane_mt:render(term, lines)
	local h = 0
	while h < self.h do
		local line = lines[h + 1] or ""
		local compare = self.lines[h + 1] or ""
		if line.peek then line = line:peek(self.w) end
		if line ~= compare then
			term:move(self.x, self.y + h)
			term:EL(2)
			io.write(line)
		end
		self.lines[h + 1] = line
		h = h + 1
	end
end


return function(x, y, w, h)
	local self = setmetatable({}, Pane_mt)
	self.x = x
	self.y = y
	self.w = w
	self.h = h
	self.lines = {}
	self.lengths = {}
	return self
end
