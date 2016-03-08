package.path = package.path .. ";./lexers/?.lua"

local lexer = require("lexer")


return {
	test_core = function()
		lexer.load("lua")
	end,
}
