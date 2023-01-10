poke(0x5F2D, 0x1) -- enable devkit mode

tool_mode = 0 -- 0 is game, 1 is frame editor, 2 is animation editor

frame_tool = {
	current_frame = 15,
	flip = false,
	show_boxes = false,
	current_box = -1
}

animation_tool = {
	current_animation = 0,
	player = make_animation_player(),
	loop = false,
	ghost = true,
	edit_mode = 0,
}
animation_names = {}
for _name, _a in pairs(animations) do
	add(animation_names, _name)
end
animation_tool.player.animation = animations[animation_names[animation_tool.current_animation+1]]

function draw_point(_x, _y, _size)
	_size = _size or 2
	line(_x - _size, _y, _x - 1, _y)
	line(_x + 1, _y, _x + _size, _y)
	line(_x, _y - _size, _x, _y - 1)
	line(_x, _y + 1, _x, _y + _size)
end

mouse_buttons = 0
prev_mouse_buttons = 0
mouse_buttons_pressed = 0
mouse_x, mouse_y = 0, 0
key = ""
prev_key = ""
key_pressed = ""

function draw_button(_min_x, _min_y, _max_x, _max_y, _col1, _col2)
	local _pressed = false
	if (mouse_buttons_pressed & 0x1) > 0 then
		if collision.point_AABB(mouse_x, mouse_y, _min_x, _min_y, _max_x, _max_y) then
			_pressed = true
		end
	end

	local _box_col = _col1
	if _pressed then
		_box_col = _col2
	end

	rectfill(_min_x, _min_y, _max_x-1, _max_y-1, _box_col)

	return _pressed
end

function draw_text_button(_x, _y, _text, _col1, _col2)
	local _w = print(_text, 0, -9999) + 2
	local _min_x, _min_y, _max_x, _max_y = _x, _y, _x + _w, _y + 7

	local _pressed = draw_button(_min_x, _min_y, _max_x, _max_y, _col1, _col2)

	local _text_col = _col2
	if _pressed then
		_text_col = _col1
	end

	print(_text, _min_x + 1, _min_y + 1, _text_col)

	return _pressed
end

game_update = _update
_update = function()

	-- KEYBOARD INPUT
	prev_key = key
	key = ""
	key_pressed = ""
	if (stat(30)) then
		key = stat(31)
		if (key ~= prev_key and key ~= "") key_pressed = key
	end

	-- MOUSE INPUT
	mouse_x, mouse_y = stat(32), stat(33)
	prev_mouse_buttons = mouse_buttons
	mouse_buttons = stat(34)
	mouse_buttons_pressed = bxor(prev_mouse_buttons, mouse_buttons) & mouse_buttons

	-- TOOL MODE
	if (key_pressed == "1") tool_mode = 0 -- GAME
	if (key_pressed == "2") tool_mode = 1 -- FRAME
	if (key_pressed == "3") tool_mode = 2 -- ANIMATION


	if tool_mode == 0 then
		if (game_update ~= nil) game_update()
	else
		if tool_mode == 1 then
			local _f = frames[frame_tool.current_frame+1]

			if frame_tool.current_box >= 0 then
				local _b = _f.boxes[frame_tool.current_box+1]

				if btn(4) then
					if (btnp(0)) _b.max_x -= 1
					if (btnp(1)) _b.max_x += 1
					if (btnp(2)) _b.max_y -= 1
					if (btnp(3)) _b.max_y += 1
				else
					if (btnp(0)) _b.min_x -= 1
					if (btnp(1)) _b.min_x += 1
					if (btnp(2)) _b.min_y -= 1
					if (btnp(3)) _b.min_y += 1
				end
			else
				if btnp(3) then
					frame_tool.current_frame = positive_mod(frame_tool.current_frame - 1, #frames)
					frame_tool.current_box = -1
				end
				if btnp(2) then
					frame_tool.current_frame = (frame_tool.current_frame + 1) % #frames
					frame_tool.current_box = -1
				end
			end
		elseif tool_mode == 2 then
			local _leftp, _rightp, _upp, _downp = btnp(0), btnp(1), btnp(2), btnp(3)
			local _a, _b = btn(4), btn(5)
			local _ap, _bp = btnp(4), btnp(5)

			animation_tool.edit_mode = 0
			if (_a) animation_tool.edit_mode = 1
			if (_b) animation_tool.edit_mode = 2

			if animation_tool.edit_mode ~= 0 then
				local _f = animation_tool.player.animation[animation_tool.player.frame+1]
				local _movement_x, _movement_y = 0, 0
				if (_leftp) _movement_x -= 1
				if (_rightp) _movement_x += 1
				if (_upp) _movement_y -= 1
				if (_downp) _movement_y += 1
				_f.movement[1] += _movement_x
				_f.movement[2] += _movement_y
				if animation_tool.edit_mode == 2 then
					local _next_frame = animation_tool.player.animation[animation_tool.player.frame+2]
					if _next_frame ~= nil then
						_next_frame.movement[1] -= _movement_x
						_next_frame.movement[2] -= _movement_y
					end
				end
			else
				if _downp then
					animation_tool.current_animation = positive_mod(animation_tool.current_animation - 1, #animation_names)
					stop_animation_player(animation_tool.player)
					local _a  = animations[animation_names[animation_tool.current_animation+1]]
					animation_tool.player.animation = _a
					animation_tool.player.frame = 0
				end
				if _upp then
					animation_tool.current_animation = (animation_tool.current_animation + 1) % #animation_names
					stop_animation_player(animation_tool.player)
					local _a  = animations[animation_names[animation_tool.current_animation+1]]
					animation_tool.player.animation = _a
					animation_tool.player.frame = 0
				end
				if _rightp then
					stop_animation_player(animation_tool.player)
					animation_tool.player.frame = (animation_tool.player.frame + 1) % #animation_tool.player.animation
				end
				if _leftp then
					stop_animation_player(animation_tool.player)
					animation_tool.player.frame = positive_mod(animation_tool.player.frame - 1, #animation_tool.player.animation)
				end
				if key_pressed == " " then
					if not animation_tool.player.is_playing then
						local _a  = animations[animation_names[animation_tool.current_animation+1]]
						play_animation_player(animation_tool.player, _a, animation_tool.loop, 0)
					else
						stop_animation_player(animation_tool.player)
					end
				end
			end
		end
	end
end

game_draw = _draw
_draw = function()

	if tool_mode == 0 then
		if game_draw ~= nil then
			game_draw()
		end
	else
		cls(5)
		if tool_mode == 1 then -- FRAME EDITOR

			local _f = frames[frame_tool.current_frame+1]
			local _origin_x, _origin_y = 64, 84
			draw_frame(_f, _origin_x, _origin_y, frame_tool.flip, frame_tool.show_boxes and frame_tool.current_box < 0)

			if frame_tool.current_box >= 0 then
				local _abs_box = make_absolute_box(_f, _f.boxes[frame_tool.current_box+1], _origin_x, _origin_y, frame_tool.flip)
				draw_box(_abs_box, 0, 0, _f.spr_w, false)
			end

			color(14)
			draw_point(_origin_x, _origin_y, 1)

			-- MENU
			cursor(1, 1, 7)
			print("frame "..frame_tool.current_frame)


			local _button_x = 1
			local _button_y = 7
			local _button_pressed = false

			if draw_text_button(_button_x, _button_y, "flip: "..bool_to_int(frame_tool.flip), 6, 7) then
				frame_tool.flip = not frame_tool.flip
				_button_pressed = true
			end
			_button_y += 8

			if draw_text_button(_button_x, _button_y, "show_boxes: "..bool_to_int(frame_tool.show_boxes), 6, 7) then
				frame_tool.show_boxes = not frame_tool.show_boxes
				_button_pressed = true
			end
			_button_y += 8

			-- EXPORT CURRENT FRAME TO CLIPBOARD
			if draw_text_button(_button_x, _button_y, "export", 3, 1) then
				local _text = ""
				for _i, _b in ipairs(_f.boxes) do
					_text = _text.."\t\t\tmake_box(\"".._b.type.."\", ".._b.min_x..", ".._b.min_y..", ".._b.max_x..", ".._b.max_y.."),"
					if (_i ~= #_f.boxes) _text = _text.."\n"
				end
				printh(_text, "@clip")
				_button_pressed = true
			end
			_button_y += 12

			local _pressed_box = -1
			for _i, _b in ipairs(_f.boxes) do
				_i -= 1
				local _text = "".._b.min_x..", ".._b.min_y..", ".._b.max_x..", ".._b.max_y
				local _col1, _col2 = 0, 0
				if (_b.type == "hit") _col1 = 2 _col2 = 8
				if (_b.type == "hurt") _col1 = 3 _col2 = 11

				if frame_tool.current_box == _i then
					rectfill(0, _button_y, 1, _button_y + 6, 7)
				end

				if draw_text_button(_button_x, _button_y, _text, _col1, _col2) then
					_pressed_box = _i
					_button_pressed = true
				end

				_button_y += 8
			end

			if _pressed_box >= 0 then
				frame_tool.current_box = _pressed_box
			elseif (mouse_buttons_pressed & 0x1) > 0 and not _button_pressed then
				frame_tool.current_box = -1
			end
		elseif tool_mode == 2 then -- ANIMATION EDITOR

			local _origin_x, _origin_y = 64, 94
			local _animation_name = animation_names[animation_tool.current_animation+1]
			local _a  = animations[_animation_name]
			local _current_frame = animation_tool.player.frame

			-- TRY TO FRAME WHOLE ANIMATION
			local _anim_min_x, _anim_min_y, _anim_max_x, _anim_max_y = get_animation_extent(_a)
			_origin_x -= (_anim_max_x - _anim_min_x) * 0.5
			_origin_y += (_anim_max_y - _anim_min_y) * 0.5

			-- DRAW GHOSTS
			if animation_tool.ghost then
				pal({6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6}, 0)
				for _i, _f in ipairs(_a) do
					if _i ~= _current_frame+1 then
						local _frame_x, _frame_y = get_animation_movement(_a, 0, _i-1)
						_frame_x += _origin_x
						_frame_y += _origin_y
						draw_frame(frames[_f.frame+1], _frame_x, _frame_y)
					end
				end
				pal()
			end

			-- DRAW CURRENT FRAME
			local _frame_x, _frame_y = get_animation_movement(_a, 0, _current_frame)
			_frame_x += _origin_x
			_frame_y += _origin_y
			--log(_frame_x)
			if animation_tool.player.is_playing then
				draw_animation_player(animation_tool.player, _frame_x, _frame_y)
			else
				draw_frame(frames[_a[_current_frame+1].frame+1], _frame_x, _frame_y)
			end

			-- DRAW ORIGIN
			color(14)
			draw_point(_origin_x, _origin_y, 1)

			-- DRAW MENU
			cursor(1, 1, 7)
			print("".._animation_name.." (".._current_frame.."/"..#_a..")")

			local _button_x = 1
			local _button_y = 7

			if draw_text_button(_button_x, _button_y, "loop: "..bool_to_int(animation_tool.loop), 6, 7) then
				animation_tool.loop = not animation_tool.loop
				animation_tool.player.is_looping = animation_tool.loop
			end
			_button_y += 8

			if draw_text_button(_button_x, _button_y, "ghost: "..bool_to_int(animation_tool.ghost), 6, 7) then
				animation_tool.ghost = not animation_tool.ghost
			end
			_button_y += 8

			-- EXPORT CURRENT ANIMATION TO CLIPBOARD
			if draw_text_button(_button_x, _button_y, "export", 3, 1) then
				local _text = ""
				for _i, _f in ipairs(_a) do
					_text = _text.."\t\t{ frame = ".._f.frame..", movement = {".._f.movement[1]..", ".._f.movement[2].."}},"
					if (_i ~= #_a) _text = _text.."\n"
				end
				printh(_text, "@clip");
			end

			_button_y += 12
			cursor(_button_x, _button_y, 7)
			print("sprite ".._a[_current_frame+1].frame)
			print("movement: ".._a[_current_frame+1].movement[1]..", ".._a[_current_frame+1].movement[2])
			local _edit_mode_str = "none"
			if (animation_tool.edit_mode == 1) _edit_mode_str = "local"
			if (animation_tool.edit_mode == 2) _edit_mode_str = "world"
			print("edit mode: ".._edit_mode_str)

			-- DRAW TIMELINE
			local _row_size = 12
			local _cell_w, _cell_h = 2, 4
			local _timeline_x = 70
			local _timeline_y = 1
			for _i, _f in ipairs(_a) do
				_i -= 1

				local _col = 13
				if (_i == _current_frame) _col = 3
				local _x = _timeline_x + (_i%_row_size)*(_cell_w+1)
				local _y = _timeline_y + flr(_i/_row_size)*(_cell_h+1)
				if draw_button(_x, _y, _x+_cell_w, _y+_cell_h, _col, 8) then
					animation_tool.player.frame = _i
				end
			end

			-- UPDATE ANIMATION
			update_animation_player(animation_tool.player)
		end

		-- DRAW_MOUSE
		color(0)
		draw_point(mouse_x, mouse_y+1, 2)
		color(7)
		draw_point(mouse_x, mouse_y, 2)
	end

	draw_log()

	print(stat(7), 120, 1)
end
