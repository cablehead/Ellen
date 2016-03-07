local ellen = require("ellen")
local k = ellen.keys

return {
	test_core = function()
		local editor = ellen.editor()

		editor:press("h")
		editor:press("i")
		assert.equal(editor.lines[1]:peek(), "hi")

		editor:press(k.ENT)
		editor:press("1")
		editor:press("2")
		editor:press("3")
		assert.equal(editor.lines[2]:peek(), "123")

		editor:press(k.BS)
		assert.equal(editor.lines[2]:peek(), "12")
		editor:press(k.BS)
		editor:press(k.BS)
		assert.equal(editor.lines[2]:peek(), "")

		editor:press(k.BS)
		assert.equal(#editor.lines, 1)
		assert.equal(editor.lines[1]:peek(), "hi")
	end,

	test_BS_merge_lines = function()
		local options = {
			lines = {"hi", "123"},
			x = 0,
			y = 2, }
		local editor = ellen.editor(options)
		editor:press(k.BS)
		assert.equal(#editor.lines, 1)
		assert.equal(editor.lines[1]:peek(), "hi123")
	end,
}
