-- coordinates origin for every position/sprite/hitbox is upper left
function make_box(_type, _min_x, _min_y, _max_x, _max_y)
	return {
		type = _type,
		min_x = _min_x,
		min_y = _min_y,
		max_x = _max_x,
		max_y = _max_y,
	}
end

function draw_box(_box, _x, _y, _w, _flip, _color)

	if _color == nil then
		_color = 7
		if (_box.type == "hit") _color = 8
		if (_box.type == "hurt") _color = 11
	end

	local min_x = _box.min_x
	local max_x = _box.max_x

	if _flip then
		min_x = 8*_w - _box.max_x
		max_x = 8*_w - _box.min_x
	end
	rect(
		_x + min_x,
		_y + _box.min_y,
		_x + max_x - 1,
		_y + _box.max_y - 1,
		_color
	)
end

function make_frame(_spr, _spr_w, _spr_h, _flip_x, _flip_y, _origin_x, _origin_y, _boxes)
	return {
    	spr = _spr,
    	spr_w = _spr_w,
    	spr_h = _spr_h,
    	flip_x = _flip_x,
    	flip_y = _flip_y,
    	origin_x = _origin_x,
    	origin_y = _origin_y,
    	boxes = _boxes or {},
  	}
end

function get_frame_upperleft_corner(_frame, _x, _y, _flip)
	_flip = _flip or false
	_flip = _flip ~= _frame.flip_x

	local _offset_x = _frame.origin_x
	if _flip then
		_offset_x = _frame.spr_w*8 - _frame.origin_x
	end

	return _x - _offset_x, _y - _frame.origin_y
end

function make_absolute_box(_frame, _box, _x, _y, _flip)
	_flip = _flip or false
	_flip = _flip ~= _frame.flip_x

	local _corner_x, _corner_y = get_frame_upperleft_corner(_frame, _x, _y, _flip)

	local min_x = _box.min_x
	local max_x = _box.max_x

	if _flip then
		min_x = 8*_frame.spr_w - _box.max_x
		max_x = 8*_frame.spr_w - _box.min_x
	end

	return make_box(
		_box.type,
		_corner_x + min_x,
		_corner_y + _box.min_y,
		_corner_x + max_x,
		_corner_y + _box.max_y
	)
end

function draw_frame(_frame, _x, _y, _flip, _draw_boxes)

	local _corner_x, _corner_y = get_frame_upperleft_corner(_frame, _x, _y, _flip)
	spr(_frame.spr, _corner_x, _corner_y, _frame.spr_w, _frame.spr_h, _flip, _frame.flip_y)

	if _draw_boxes then
		for _i, _b in ipairs(_frame.boxes) do
			local _abs_box = make_absolute_box(_frame, _b, _x, _y, _flip)
			draw_box(_abs_box, 0, 0, _frame.spr_w, false)
		end
	end
end

function make_animation_player()
	return {
		animation = nil,
		frame = -1,
		is_looping = false,
	}
end

function play_animation(_player, _animation, _loop)
	if _player.animation == _animation then
		return
	end

	_player.animation = _animation
	_player.frame = 0
	_player.is_looping = _loop

end

function update_animation(_player)
	if _player.animation ~= nil then
		_player.frame = (_player.frame + 1)
		if _player.frame >= #_player.animation then
			if _player.is_looping then
				_player.frame = 0
			else
				_player.animation = nil
			end
		end
	end
end

function draw_animation(_player, _x, _y, _flip)
	if _player.animation ~= nil then
		local animation_frame = frames[_player.animation[_player.frame + 1] + 1]
		draw_frame(animation_frame, _x, _y, _flip)
	end 
end
