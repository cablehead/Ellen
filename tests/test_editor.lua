local ellen = require("ellen")
local k = ellen.keys

local Editor = ellen.editor.Editor
local I = ellen.editor.I


return {
	test_input = function()
		local got = {}
		for ch in I("i123", k.ESC, ".") do
			table.insert(got, ch)
		end
		assert.same(got, {"i", "1", "2", "3", k.ESC, "."})
	end,

	test_core = function()
		local editor = Editor()

		editor:run(I("ihi"))
		assert.equal(editor.lines[1]:peek(), "hi")

		editor:run(I(k.ENT, "123"))
		assert.equal(editor.lines[2]:peek(), "123")

		editor:run(I(k.BS))
		assert.equal(editor.lines[2]:peek(), "12")
		editor:run(I(k.BS, k.BS))
		assert.equal(editor.lines[2]:peek(), "")

		editor:run(I(k.BS))
		assert.equal(#editor.lines, 1)
		assert.equal(editor.lines[1]:peek(), "hi")
	end,

	test_bounds = function()
		local editor = Editor()
		editor:run("h")
		assert.equal(editor.x, 1)
		editor:run("l")
		assert.equal(editor.x, 1)
		editor:run("k")
		assert.equal(editor.y, 1)
		editor:run("j")
		assert.equal(editor.y, 1)
	end,

	test_BS_merge_lines = function()
		local options = {
			lines = {"hi", "123"},
			x = 1,
			y = 2, }
		local editor = Editor(options)
		editor:run(I("i", k.BS))
		assert.equal(#editor.lines, 1)
		assert.equal(editor.lines[1]:peek(), "hi123")
	end,

	test_BS_blank_merge_lines = function()
		local options = {
			lines = {"", ""},
			x = 1,
			y = 2, }
		local editor = Editor(options)
		editor:run(I("i", k.BS))
		assert.equal(#editor.lines, 1)
		assert.equal(editor.lines[1]:peek(), "")
	end,

	test_a = function()
		local options = {
			lines = {"hi"},
			x = 1,
			y = 1, }

		local editor = Editor(options)
		editor:run(I("a2"))
		assert.equal(editor.lines[1]:peek(), "h2i")
	end,

	test_I = function()
		local options = {
			lines = {"123"},
			x = 4,
			y = 1, }

		local editor = Editor(options)
		editor:run(I("I4"))
		assert.equal(editor.lines[1]:peek(), "4123")
	end,

	test_o = function()
		local options = {
			lines = {"hi", "123"},
			x = 2,
			y = 1, }

		local editor = Editor(options)
		editor:run(I("omo"))
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

		local editor = Editor(options)
		editor:run(I("Omo"))
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

		local editor = Editor(options)
		editor:run(I("da1dd"))
		assert.equal(#editor.lines, 2)
		assert.equal(editor.lines[1]:peek(), "hi")
		assert.equal(editor.lines[2]:peek(), "line3")
	end,

	test_dot_no_last = function()
		local editor = Editor()
		editor:run(I("."))
	end,

	test_dot_i = function()
		local editor = Editor()
		editor:run(I("i123", k.ESC, "."))
		assert.equal(editor.lines[1]:peek(), "121233")
	end,

	test_dot_dd = function()
		local options = {
			lines = {"hi", "123", "line3"},
			x = 1,
			y = 2, }

		local editor = Editor(options)
		editor:run(I("da1dd."))
		assert.equal(#editor.lines, 1)
		assert.equal(editor.lines[1]:peek(), "hi")
	end,
}
