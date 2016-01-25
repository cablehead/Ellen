return {
	test_core = function()
		print()
		print()
		local line = require("ellen.line")()

		line:put("foo")
		line:put("bar")

		line.x = line.x - 2
		line:put("123")

		for i, span in ipairs(line.spans) do
			print("--", span:peek())
		end

		print()
	end,
}
