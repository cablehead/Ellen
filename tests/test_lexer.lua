local lexer = require("ellen.lexer")
local I = require("ellen.editor").I


return {
	test_core = function()
		print()
		print()
		local l = lexer(I("3a.49x3d10w"))
	end,
}
