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

	local h = 0

	local color = txtrst
	local current = {color}

	local function write()
		if color ~= txtrst then table.insert(current, txtrst) end
		current = table.concat(current)
		local compare = self.lines[h + 1] or ""
		if current ~= compare then
			term:move(self.x, self.y + h)
			io.write(current)
			term:EL()
		end
		h = h + 1
		self.lines[h] = current
		current = {color}
	end

	for c in text:gmatch(".") do
		i = i + 1
		if i == nxt then
			token, nxt = itokens()
			color = colors[token] or txtrst
			table.insert(current, color)
		end

		if c == "\n" then
			write()
		else
			table.insert(current, c)
		end
	end

	write()

	for i = h, #self.lines do
		if #(self.lines[i] or "") > 0 then
			term:move(self.x, self.y + i)
			term:EL()
			self.lines[i] = nil
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
			io.write(line)
			io.write((" "):rep(self.w-#line-1))
		end
		self.lines[h + 1] = line
		h = h + 1
	end
end


function Pane_mt:move(term, x, y)
	term:move(math.max(self.x + x - 1, self.x), math.max(self.y + y - 1, self.y))
end


return function(x, y, w, h)
	local self = setmetatable({}, Pane_mt)
	self.x = x
	self.y = y
	self.w = w
	self.h = h
	self.lines = {}
	return self
end
