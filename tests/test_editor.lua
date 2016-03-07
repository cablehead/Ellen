local ellen = require("ellen")

return {
	test_core = function()
		local editor = ellen.editor()
		local k = ellen.keys

		editor:press("h")
		editor:press("i")
		assert(editor.lines[1]:peek(), "hi")

		editor:press(k.ENT)
		editor:press("1")
		editor:press("2")
		editor:press("3")
		assert(editor.lines[2]:peek(), "123")

		editor:press(k.BS)
		assert(editor.lines[2]:peek(), "12")
		editor:press(k.BS)
		editor:press(k.BS)
		assert(editor.lines[2]:peek(), "")

		editor:press(k.BS)
		assert(#editor.lines, 1)
		assert(editor.lines[1]:peek(), "hi")
	end,
}
