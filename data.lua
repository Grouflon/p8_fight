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
	idle = {
		{ frame = 0, movement = {0, 0}},
		{ frame = 0, movement = {0, 0}},
		{ frame = 0, movement = {0, 0}},
		{ frame = 0, movement = {0, 0}},
		{ frame = 0, movement = {0, 0}},
		{ frame = 0, movement = {0, 0}},
		{ frame = 0, movement = {0, 0}},
		{ frame = 0, movement = {0, 0}},
		{ frame = 0, movement = {0, 0}},
		{ frame = 0, movement = {0, 0}},
		{ frame = 0, movement = {0, 0}},
		{ frame = 0, movement = {0, 0}},
		{ frame = 0, movement = {0, 0}},
		{ frame = 0, movement = {0, 0}},
		{ frame = 0, movement = {0, 0}},
		{ frame = 0, movement = {0, 0}},
		{ frame = 1, movement = {0, 0}},
		{ frame = 1, movement = {0, 0}},
		{ frame = 1, movement = {0, 0}},
		{ frame = 1, movement = {0, 0}},
		{ frame = 1, movement = {0, 0}},
		{ frame = 1, movement = {0, 0}},
		{ frame = 1, movement = {0, 0}},
		{ frame = 1, movement = {0, 0}},
	},
	walk = {
		{ frame = 4, movement = {0, 0}},
		{ frame = 4, movement = {0, 0}},
		{ frame = 4, movement = {0, 0}},
		{ frame = 4, movement = {0, 0}},
		{ frame = 5, movement = {0, 0}},
		{ frame = 5, movement = {0, 0}},
		{ frame = 5, movement = {0, 0}},
		{ frame = 5, movement = {0, 0}},
	},
	punch = {
		{ frame = 2, movement = {0, 0}},
		{ frame = 3, movement = {0, 0}},
		{ frame = 3, movement = {0, 0}},
		{ frame = 3, movement = {0, 0}},
		{ frame = 2, movement = {0, 0}},
		{ frame = 2, movement = {0, 0}},
	},
	kick = {
		{ frame = 6, movement = {0, 0}},
		{ frame = 6, movement = {0, 0}},
		{ frame = 6, movement = {0, 0}},
		{ frame = 6, movement = {0, 0}},
		{ frame = 7, movement = {0, 0}},
		{ frame = 7, movement = {0, 0}},
		{ frame = 7, movement = {0, 0}},
		{ frame = 6, movement = {0, 0}},
		{ frame = 6, movement = {0, 0}},
		{ frame = 6, movement = {0, 0}},
		{ frame = 6, movement = {0, 0}},
		{ frame = 6, movement = {0, 0}},
	},
	jump = {
		{ frame = 8, movement = {2, -3}},
		{ frame = 8, movement = {2, -3}},
		{ frame = 8, movement = {2, -3}},
		{ frame = 8, movement = {2, -2}},
		{ frame = 9, movement = {2, -2}},
		{ frame = 9, movement = {2, -2}},
		{ frame = 9, movement = {2, -1}},
		{ frame = 9, movement = {2, -1}},
		{ frame = 10, movement = {2, -1}},
		{ frame = 10, movement = {2, 0}},
		{ frame = 10, movement = {2, 0}},
		{ frame = 10, movement = {2, 0}},
		{ frame = 11, movement = {2, 1}},
		{ frame = 11, movement = {2, 1}},
		{ frame = 11, movement = {2, 1}},
		{ frame = 11, movement = {2, 2}},
		{ frame = 8, movement = {2, 2}},
		{ frame = 8, movement = {2, 2}},
		{ frame = 8, movement = {2, 3}},
		{ frame = 8, movement = {2, 3}},
		{ frame = 9, movement = {2, 3}},
	},
	jump_kick = {
		{ frame = 12, movement = {0, 0}},
	}
}