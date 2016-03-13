--[[

                                       │
                                       │
                                       │
                                       │
                                       │
                                       │
                                       │
status bar: status ────────────────────┴─────────────────────────
--]]


return {

	hsplit = function(cols)
		local w1 = math.ceil((cols - 1) / 2)
		return {{0, w1}, {w1, 1}, {w1+1, cols-w1-1}}
	end,

	HR = "─",
	VR = "│",
	AW = "┼",
	SD = "┬",
	SU = "┴",
	SR = "├",
	SL = "┤", }
