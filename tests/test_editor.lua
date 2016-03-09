local ellen = require("ellen")
local k = ellen.keys

return {
	test_dot = function()
		local editor = ellen.editor()
		editor:press("123")
		assert.equal(editor.lines[1]:peek(), "123")
	end,

	test_core = function()
		local editor = ellen.editor()

		editor:press("hi")
		assert.equal(editor.lines[1]:peek(), "hi")

		editor:press(k.ENT, "123")
		assert.equal(editor.lines[2]:peek(), "123")

		editor:press(k.BS)
		assert.equal(editor.lines[2]:peek(), "12")
		editor:press(k.BS, k.BS)
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

	test_BS_blank_merge_lines = function()
		local options = {
			lines = {"", ""},
			x = 0,
			y = 2, }
		local editor = ellen.editor(options)
		editor:press(k.BS)
		assert.equal(#editor.lines, 1)
		assert.equal(editor.lines[1]:peek(), "")
	end,

	test_a = function()
		local options = {
			lines = {"hi"},
			x = 1,
			y = 1, }

		local editor = ellen.editor(options)
		editor:press(k.ESC)
		editor:press("a")
		editor:press("2")
		assert.equal(editor.lines[1]:peek(), "h2i")
	end,

	test_I = function()
		local options = {
			lines = {"123"},
			x = 3,
			y = 1, }

		local editor = ellen.editor(options)
		editor:press(k.ESC)
		editor:press("I")
		editor:press("4")
		assert.equal(editor.lines[1]:peek(), "4123")
	end,

	test_o = function()
		local options = {
			lines = {"hi", "123"},
			x = 1,
			y = 1, }

		local editor = ellen.editor(options)
		editor:press(k.ESC)
		editor:press("o")
		editor:press("m")
		editor:press("o")
		assert.equal(#editor.lines, 3)
		assert.equal(editor.lines[1]:peek(), "hi")
		assert.equal(editor.lines[2]:peek(), "mo")
		assert.equal(editor.lines[3]:peek(), "123")
	end,

	test_O = function()
		local options = {
			lines = {"hi", "123"},
			x = 1,
			y = 1, }

		local editor = ellen.editor(options)
		editor:press(k.ESC)
		editor:press("O")
		editor:press("m")
		editor:press("o")
		assert.equal(#editor.lines, 3)
		assert.equal(editor.lines[1]:peek(), "mo")
		assert.equal(editor.lines[2]:peek(), "hi")
		assert.equal(editor.lines[3]:peek(), "123")
	end,

	test_dd = function()
		local options = {
			lines = {"hi", "123", "line3"},
			x = 1,
			y = 2, }

		local editor = ellen.editor(options)
		editor:press(k.ESC)
		editor:press("d")
		editor:press("a")
		editor:press("1")
		editor:press("d")
		editor:press("d")
		assert.equal(#editor.lines, 2)
		assert.equal(editor.lines[1]:peek(), "hi")
		assert.equal(editor.lines[2]:peek(), "line3")
	end,
}
