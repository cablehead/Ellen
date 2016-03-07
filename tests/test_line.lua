return {
	test_core = function()
		local line = require("ellen.line")()
		assert.equal(line:splice(0, 0, "foo"), "")
		assert.equal(line:peek(), "foo")
		assert.equal(line:splice(3, 0, "bar"), "")
		assert.equal(line:peek(), "foobar")
		assert.equal(line:splice(3, 0, "123"), "")
		assert.equal(line:peek(), "foo123bar")
		assert.equal(line:splice(6, 1), "b")
		assert.equal(line:peek(), "foo123ar")
		assert.equal(line:splice(7, 1), "r")
		assert.equal(line:peek(), "foo123a")
		assert.equal(line:splice(3), "123a")
		assert.equal(line:peek(), "foo")
	end,
}
