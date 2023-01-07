frames = {
	-- 0 - IDLE
	make_frame(
		-- sprite
		0, 1, 2, false, false,
		-- origin
		3, 16,
		-- boxes
		{
			make_box("hurt", 2, 3, 5, 16),
			make_box("hurt", 1, 7, 6, 10),
		}
	),
	-- 1 - IDLE
	make_frame(
		-- sprite
		1, 1, 2, false, false,
		-- origin
		3, 16,
		-- boxes
		{
			make_box("hurt", 2, 3, 5, 16),
			make_box("hurt", 1, 7, 6, 10),
		}
	),
	-- 2 - PUNCH
	make_frame(
		-- sprite
		2, 1, 2, false, false,
		-- origin
		3, 16,
		-- boxes
		{
			make_box("hurt", 2, 3, 5, 16),
			make_box("hurt", 2, 6, 7, 9),
		}
	),
	-- 3 - PUNCH
	make_frame(
		-- sprite
		3, 1, 2, false, false,
		-- origin
		3, 16,
		-- boxes
		{ 
			make_box("hurt", 2, 3, 5, 16),
			make_box("hit", 5, 6, 8, 8),
		}
	),
	-- 4 - WALK
	make_frame(
		-- sprite
		4, 1, 2, false, false,
		-- origin
		3, 16,
		-- boxes
		{
			make_box("hurt", 2, 3, 5, 16),
			make_box("hurt", 1, 7, 6, 10),
		}
	),
	-- 5 - WALK
	make_frame(
		-- sprite
		5, 1, 2, false, false,
		-- origin
		3, 16,
		-- boxes
		{
			make_box("hurt", 2, 3, 5, 16),
			make_box("hurt", 1, 7, 6, 10),
		}
	),
	-- 6 - KICK
	make_frame(
		-- sprite
		6, 1, 2, false, false,
		-- origin
		3, 16,
		-- boxes
		{
			make_box("hurt", 2, 3, 5, 16),
			make_box("hurt", 5, 8, 7, 13),
		}
	),
	-- 7 - KICK
	make_frame(
		-- sprite
		7, 2, 2, false, false,
		-- origin
		4, 16,
		-- boxes
		{ 
			make_box("hurt", 2, 3, 5, 10),
			make_box("hurt", 4, 7, 7, 16),
			make_box("hit", 7, 8, 12, 11),
		}
	),
	-- 8 - JUMP0
	make_frame(
		-- sprite
		9, 1, 1, false, false,
		-- origin
		4, 8,
		-- boxes
		{
			make_box("hurt", 2, 0, 5, 7),
			make_box("hurt", 1, 3, 6, 6),
		}
	),
	-- 9 - JUMP1
	make_frame(
		-- sprite
		10, 1, 1, false, false,
		-- origin
		4, 8,
		-- boxes
		{
			make_box("hurt", 2, 1, 5, 6),
			make_box("hurt", 1, 2, 6, 5),
		}
	),
	-- 10 - JUMP2
	make_frame(
		-- sprite
		9, 1, 1, true, true,
		-- origin
		4, 8,
		-- boxes
		{
			make_box("hurt", 2, 0, 5, 7),
			make_box("hurt", 1, 2, 6, 5),
		}
	),
	-- 11 - JUMP3
	make_frame(
		-- sprite
		10, 1, 1, true, true,
		-- origin
		4, 8,
		-- boxes
		{
			make_box("hurt", 2, 2, 5, 7),
			make_box("hurt", 1, 3, 6, 6),
		}
	),
	-- 12 - JUMP KICK
	make_frame(
		-- sprite
		25, 2, 1, false, false,
		-- origin
		4, 8,
		-- boxes
		{ 
			make_box("hurt", 2, 0, 6, 7),
			make_box("hurt", 1, 3, 9, 6),
			make_box("hit", 6, 5, 12, 8),
		}
	),
}

animations = {
	idle = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1 },
	walk = { 4, 4, 4, 4, 5, 5, 5, 5 },
	punch = { 2, 3, 3, 3, 2, 2 },
	kick = { 6, 6, 6, 6, 7, 7, 7, 6, 6, 6, 6, 6 },
	jump = { 8, 8, 8, 8, 9, 9, 9, 9, 10, 10, 10, 10, 11, 11, 11, 11 },
	jump_kick = { 12 }
}