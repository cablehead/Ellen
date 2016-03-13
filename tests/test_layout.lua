local levee = require("levee")
local _ = require("levee")._

local ellen = require("ellen")
local term = ellen.term()

local l = require("ellen.layout")


return {
	test_core = function()
		print()
		local h = levee.Hub()
		local err, ws = _.term.winsize(1)
		for i = 1, 5 do
			io.write((" "):rep(ws.col / 2))
			io.write(l.VR)
			io.write("\n")
		end
	end,

	test_split = function()
		assert.same(l.split(5), {{0, 2}, {2, 1}, {3, 2}})
		assert.same(l.split(6), {{0, 3}, {3, 1}, {4, 2}})
	end,
}
