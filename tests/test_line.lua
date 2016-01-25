return {
	test_core = function()
		print()
		print()
		local line = require("ellen.line")()

		line:put(0, "foo")
		line:put(3, "bar")
		line:put(4, "123")

		for i, span in ipairs(line.spans) do
			print("--", span:peek())
		end

		print(line:tail(4))
		print(line:tail(8))

		print()
	end,
}
