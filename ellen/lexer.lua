local function N(input)
	local n = 0
	while true do
		local err, ch = input:peek()
		if err then return err end
		local i = ch:match("%d")
		if not i then break end
		n = (10 * n) + i
		input:recv()
	end
	if n == 0 then n = 1 end
	return nil, n
end


local function NOUN(input)
	local err, ch = input:recv()
	if err then return err end
	return nil, ch:match("[dw]")
end


local function DEL(input)
	local err, n = N(input)
	if err then return err end
	local err, noun = NOUN(input)
	if err then return err end
	return nil, n, noun
end


return function(input)
	while true do
		local err, n = N(input)
		if err then return err end

		local err, ch = input:recv()
		if err then return err end

		if ch == "d" then
			print("DEL", n, DEL(input))
		end
	end
end
