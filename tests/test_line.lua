return {
	test_core = function()
		local line = require("ellen.line")()
		assert.equal(line:splice(1), "")
		assert.equal(line:peek(), "")

		assert.equal(line:splice(1, 0, line:peek()), "")
		assert.equal(line:peek(), "")

		assert.equal(line:splice(1, 0, "foo"), "")
		assert.equal(line:peek(), "foo")

		assert.equal(line:splice(4, 0, "bar"), "")
		assert.equal(line:peek(), "foobar")

		assert.equal(line:splice(4, 0, "123"), "")
		assert.equal(line:peek(), "foo123bar")

		assert.equal(line:splice(7, 1), "b")
		assert.equal(line:peek(), "foo123ar")

		assert.equal(line:splice(8, 1), "r")
		assert.equal(line:peek(), "foo123a")

		assert.equal(line:splice(4), "123a")
		assert.equal(line:peek(), "foo")

		assert.equal(line:splice(4), "")
		assert.equal(line:peek(), "foo")
	end,

	test_slice = function()
		local line = require("ellen.line")("foobar")
		assert.equal(line:slice(), "foobar")
		assert.equal(line:slice(2), "oobar")
		assert.equal(line:slice(-1), "foobar")
		assert.equal(line:slice(15), "")
		assert.equal(line:slice(nil, 3), "foo")
		assert.equal(line:slice(nil, -1), "")
		assert.equal(line:slice(nil, 15), "foobar")
		assert.equal(line:slice(3, 4), "obar")
	end,
}
