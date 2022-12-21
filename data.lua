frames = {
	-- 0 - IDLE
	make_frame(
		-- sprite
		0, 1, 2, false, false,
		-- origin
		3, 16,
		-- hitboxes
		{ 
		},
		-- hurtboxes
		{
			make_box(2, 3, 3, 13),
			make_box(1, 7, 5, 3),
		}
	),
	-- 1 - IDLE
	make_frame(
		-- sprite
		1, 1, 2, false, false,
		-- origin
		3, 16,
		-- hitboxes
		{ 
		},
		-- hurtboxes
		{
			make_box(2, 3, 3, 13),
			make_box(1, 7, 5, 3),
		}
	),
	-- 2 - PUNCH
	make_frame(
		-- sprite
		2, 1, 2, false, false,
		-- origin
		3, 16,
		-- hitboxes
		{ 
		},
		-- hurtboxes
		{
			make_box(2, 3, 3, 13),
			make_box(2, 6, 5, 3),
		}
	),
	-- 3 - PUNCH
	make_frame(
		-- sprite
		3, 1, 2, false, false,
		-- origin
		3, 16,
		-- hitboxes
		{ 
			make_box(5, 6, 3, 2),
		},
		-- hurtboxes
		{
			make_box(2, 3, 3, 13),
		}
	),
	-- 4 - WALK
	make_frame(
		-- sprite
		4, 1, 2, false, false,
		-- origin
		3, 16,
		-- hitboxes
		{ 
		},
		-- hurtboxes
		{
			make_box(2, 3, 3, 13),
			make_box(1, 7, 5, 3),
		}
	),
	-- 5 - WALK
	make_frame(
		-- sprite
		5, 1, 2, false, false,
		-- origin
		3, 16,
		-- hitboxes
		{ 
		},
		-- hurtboxes
		{
			make_box(2, 3, 3, 13),
			make_box(1, 7, 5, 3),
		}
	),
	-- 6 - KICK
	make_frame(
		-- sprite
		6, 1, 2, false, false,
		-- origin
		3, 16,
		-- hitboxes
		{ 
		},
		-- hurtboxes
		{
			make_box(2, 3, 3, 13),
			make_box(5, 8, 2, 5),
		}
	),
	-- 7 - KICK
	make_frame(
		-- sprite
		7, 2, 2, false, false,
		-- origin
		4, 16,
		-- hitboxes
		{ 
			make_box(7, 8, 5, 3),
		},
		-- hurtboxes
		{
			make_box(2, 3, 3, 7),
			make_box(4, 7, 3, 9),
		}
	),
	-- 8 - JUMP0
	make_frame(
		-- sprite
		9, 1, 1, false, false,
		-- origin
		4, 8,
		-- hitboxes
		{ 
		},
		-- hurtboxes
		{
			make_box(2, 0, 3, 7),
			make_box(1, 3, 5, 3),
		}
	),
	-- 9 - JUMP1
	make_frame(
		-- sprite
		10, 1, 1, false, false,
		-- origin
		4, 8,
		-- hitboxes
		{ 
		},
		-- hurtboxes
		{
			make_box(2, 1, 3, 5),
			make_box(1, 2, 5, 3),
		}
	),
	-- 10 - JUMP2
	make_frame(
		-- sprite
		9, 1, 1, true, true,
		-- origin
		4, 8,
		-- hitboxes
		{ 
		},
		-- hurtboxes
		{
			make_box(2, 0, 3, 7),
			make_box(1, 2, 5, 3),
		}
	),
	-- 11 - JUMP3
	make_frame(
		-- sprite
		10, 1, 1, true, true,
		-- origin
		4, 8,
		-- hitboxes
		{ 
		},
		-- hurtboxes
		{
			make_box(2, 2, 3, 5),
			make_box(1, 3, 5, 3),
		}
	),
	-- 12 - JUMP KICK
	make_frame(
		-- sprite
		25, 2, 1, false, false,
		-- origin
		4, 8,
		-- hitboxes
		{ 
			make_box(6, 5, 6, 3),
		},
		-- hurtboxes
		{
			make_box(2, 0, 4, 7),
			make_box(1, 3, 8, 3),
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