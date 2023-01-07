poke(0x5F2D, 0x1) -- enable devkit mode

tool_mode = 0 -- 0 is game, 1 is frame editor, 2 is animation editor

frame_tool = {
	current_frame = 0,
	flip = false,
	show_boxes = false,
	current_box = -1
}

animation_tool = {
	current_animation = 0,
	player = make_animation_player(),
	loop = false,
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

game_update = _update
_update = function()

	-- TOOL MODE
	if (stat(30)) then
		local _key = stat(31)
		if (_key == "1") tool_mode = 0 -- GAME
		if (_key == "2") tool_mode = 1 -- FRAME
		if (_key == "3") tool_mode = 2 -- ANIMATION
	end

	if tool_mode == 0 then
		if (game_update ~= nil) game_update()
	else
		-- MOUSE INPUT
		mouse_x, mouse_y = stat(32), stat(33)
		prev_mouse_buttons = mouse_buttons
		mouse_buttons = stat(34)
		mouse_buttons_pressed = bxor(prev_mouse_buttons, mouse_buttons) & mouse_buttons

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
				if btnp(0) then
					frame_tool.current_frame = positive_mod(frame_tool.current_frame - 1, #frames)
					frame_tool.current_box = -1
				end
				if btnp(1) then
					frame_tool.current_frame = (frame_tool.current_frame + 1) % #frames
					frame_tool.current_box = -1
				end
			end
		elseif tool_mode == 2 then
			if btnp(0) then
				animation_tool.current_animation = positive_mod(animation_tool.current_animation - 1, #animation_names)
				stop_animation(animation_tool.player)
				local _a  = animations[animation_names[animation_tool.current_animation+1]]
				animation_tool.player.animation = _a
				animation_tool.player.frame = 0
			end
			if btnp(1) then
				animation_tool.current_animation = (animation_tool.current_animation + 1) % #animation_names
				stop_animation(animation_tool.player)
				local _a  = animations[animation_names[animation_tool.current_animation+1]]
				animation_tool.player.animation = _a
				animation_tool.player.frame = 0
			end
			if btnp(4) then
				if not animation_tool.player.is_playing then
					local _a  = animations[animation_names[animation_tool.current_animation+1]]
					play_animation(animation_tool.player, _a, animation_tool.loop, 0)
				else
					stop_animation(animation_tool.player)
				end
			end
		end
	end

	-- BEZIER CURVE DEBUGGER
	if false then
		if btn(5) then
			if btn(0) then
				w1 = w1 - 1
			end
			if btn(1) then
				w1 = w1 + 1
			end
			w1 = mid(w1, -w0, w0)
			if btn(2) then
				h = h + 1
			end
			if btn(3) then
				h = h - 1
			end
		end

		if btn(4) then
			if btn(0) then
				w0 = w0 - 1
			end
			if btn(1) then
				w0 = w0 + 1
			end
			w1 = mid(w1, -w0, w0)
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
		function draw_button(_x, _y, _text, _col1, _col2)
			local _w = print(_text, 0, -9999) + 2
			local _min_x, _min_y, _max_x, _max_y = _x, _y, _x + _w, _y + 6

			local _pressed = false
			if (mouse_buttons_pressed & 0x1) > 0 then
				if collision.point_box(mouse_x, mouse_y, _min_x, _min_y, _max_x, _max_y) then
					_pressed = true
				end
			end

			local _box_col = _col1
			local _text_col = _col2
			if _pressed then
				_box_col = _col2
				_text_col = _col1
			end

			rectfill(_min_x, _min_y, _max_x, _max_y, _box_col)
			print(_text, _min_x + 1, _min_y + 1, _text_col)

			return _pressed
		end

		cls(5)
		if tool_mode == 1 then

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

			if draw_button(_button_x, _button_y, "flip: "..bool_to_int(frame_tool.flip), 6, 7) then
				frame_tool.flip = not frame_tool.flip
				_button_pressed = true
			end
			_button_y += 8

			if draw_button(_button_x, _button_y, "show_boxes: "..bool_to_int(frame_tool.show_boxes), 6, 7) then
				frame_tool.show_boxes = not frame_tool.show_boxes
				_button_pressed = true
			end
			_button_y += 8

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

				if draw_button(_button_x, _button_y, _text, _col1, _col2) then
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
		elseif tool_mode == 2 then

			local _origin_x, _origin_y = 64, 84
			local _animation_name = animation_names[animation_tool.current_animation+1]
			local _a  = animations[_animation_name]
			local _current_frame = 0

			if animation_tool.player.animation ~= nil then
				draw_animation(animation_tool.player, _origin_x, _origin_y)
				_current_frame = animation_tool.player.frame
			else
				draw_frame(frames[_a[1]+1], _origin_x, _origin_y)
			end

			cursor(1, 1, 7)
			print("".._animation_name.." (".._current_frame.."/"..#_a..")")

			local _button_x = 1
			local _button_y = 7
			if draw_button(_button_x, _button_y, "loop: "..bool_to_int(animation_tool.loop), 6, 7) then
				animation_tool.loop = not animation_tool.loop
				animation_tool.player.is_looping = animation_tool.loop
			end
			_button_y += 8

			update_animation(animation_tool.player)
		end

		-- DRAW_MOUSE
		color(0)
		draw_point(mouse_x, mouse_y+1, 2)
		color(7)
		draw_point(mouse_x, mouse_y, 2)
	end

	-- BEZIER CURVE DEBUGGER
	if false then
		local _jump = make_jump(14, 100, w0, w1, h)

		pset(_jump.p0.x, _jump.p0.y, 8)
		pset(_jump.p1.x, _jump.p1.y, 8)
		pset(_jump.p2.x, _jump.p2.y, 8)
		pset(_jump.p3.x, _jump.p3.y, 8)

		color(6)
		line(_jump.p0.x, _jump.p0.y, _jump.p0.x, _jump.p0.y)

		for i=0,10 do
			local p = compute_jump_position(_jump, i/10)

			pset(p.x, p.y)
			--line(p.x, p.y)
		end
		print("w0:"..w0)
		print("w1:"..w1)
		print("h:"..h)
	end

	draw_log()

	print(stat(7), 120, 1)
end
