return {
	test_core = function()
		print()
		print()
		local spans = require("ellen.spans")()

		spans:put("foo")
		spans:put("bar")

		spans.x = spans.x - 2
		spans:put("123")

		for i, span in ipairs(spans.spans) do
			print("--", span:peek())
		end

		print()
	end,
}
