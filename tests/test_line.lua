return {
	test_core = function()
		local line = require("ellen.line")()
		line:splice(0, 0, "foo")
		assert.equal(line:peek(), "foo")
		line:splice(3, 0, "bar")
		assert.equal(line:peek(), "foobar")
		line:splice(3, 0, "123")
		assert.equal(line:peek(), "foo123bar")
		line:splice(6, 1)
		assert.equal(line:peek(), "foo123ar")
		line:splice(7, 1)
		assert.equal(line:peek(), "foo123a")
	end,
}
