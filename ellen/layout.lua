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

	split = function(n)
		local w1 = math.ceil((n - 1) / 2)
		return {{0, w1}, {w1, 1}, {w1+1, n-w1-1}}
	end,

	HR = "─",
	VR = "│",
	AW = "┼",
	SD = "┬",
	SU = "┴",
	SR = "├",
	SL = "┤", }
