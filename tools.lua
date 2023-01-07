poke(0x5F2D, 0x1) -- enable devkit mode

tool_mode = 0 -- 0 is game, 1 is frame editor, 2 is animation editor

frame_tool = {
	current_frame = 0,
	flip = false,
	show_boxes = false,
	current_box = -1
}

function draw_point(_x, _y, _size)
	_size = _size or 2
	line(_x - _size, _y, _x - 1, _y)
	line(_x + 1, _y, _x + _size, _y)
	line(_x, _y - _size, _x, _y - 1)
	line(_x, _y + 1, _x, _y + _size)
end

game_update = _update
_update = function()

	-- TOOL MODE
	if (stat(30)) then
		local _key = stat(31)
		if _key == "1" then
			tool_mode = 0
		elseif _key == "2" then
			tool_mode = 1
		end
	end

	if tool_mode == 0 then
		if game_update ~= nil then
			game_update()
		end
	elseif tool_mode == 1 then
		if btnp(0) then
			frame_tool.current_frame = positive_mod(frame_tool.current_frame - 1, #frames)
			frame_tool.current_box = -1
		end
		if btnp(1) then
			frame_tool.current_frame = (frame_tool.current_frame + 1) % #frames
			frame_tool.current_box = -1
		end

		if btnp(4) then
			frame_tool.show_boxes = not frame_tool.show_boxes
		end
		if btnp(5) then
			frame_tool.flip = not frame_tool.flip
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
		local _mouse_x, _mouse_y = stat(32), stat(33)
		local _mouse_buttons = stat(34)

		cls(5)
		if tool_mode == 1 then

			local _f = frames[frame_tool.current_frame + 1]
			local _origin_x, _origin_y = 64, 64
			draw_frame(_f, _origin_x, _origin_y, frame_tool.flip, frame_tool.show_boxes and frame_tool.current_box < 0)

			if frame_tool.current_box >= 0 then
				local _abs_box = make_absolute_box(_f, _f.boxes[frame_tool.current_box], _origin_x, _origin_y, frame_tool.flip)
				draw_box(_abs_box, 0, 0, _f.spr_w, false)
			end

			color(14)
			draw_point(_origin_x, _origin_y, 1)

			local _box_count = 0
			local _base_x = 1
			local _base_y = 13

			for _i, _b in ipairs(_f.boxes) do
				local _text = "".._b.min_x..", ".._b.min_y..", ".._b.max_x..", ".._b.max_y
				local _w = print(_text, 0, -9999) + 2
				local _y = _base_y + 8*_box_count
				local _min_x, _min_y, _max_x, _max_y = _base_x, _y, _base_x + _w, _y + 6

				if (_mouse_buttons & 0x1) > 0 then
					if collision.point_box(_mouse_x, _mouse_y, _min_x, _min_y, _max_x, _max_y) then
						frame_tool.current_box = _i
					elseif frame_tool.current_box == _i then
						frame_tool.current_box = -1
					end
				end

				if frame_tool.current_box == _i then
					rectfill(0, _min_y, _min_x, _max_y, 7)
				end

				local _col1, _col2 = 0, 0
				if (_b.type == "hit") _col1 = 2 _col2 = 8
				if (_b.type == "hurt") _col1 = 3 _col2 = 11
				rectfill(_min_x, _min_y, _max_x, _max_y, _col1)
				print(_text, _min_x + 1, _min_y + 1, _col2)

				_box_count += 1
			end

			cursor(1, 1, 7)
			print("frame "..frame_tool.current_frame)
			print("flip: "..bool_to_int(frame_tool.flip))
		end

		-- DRAW_MOUSE
		color(0)
		draw_point(_mouse_x, _mouse_y+1, 2)
		color(7)
		draw_point(_mouse_x, _mouse_y, 2)
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