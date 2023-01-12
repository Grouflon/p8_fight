box_types = {
	"hurt",
	"hit",
	"push"
}

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
	assert(_box ~= nil)
	if _color == nil then
		_color = 7
		if (_box.type == 0) _color = 11 -- hurt
		if (_box.type == 1) _color = 8  -- hit
		if (_box.type == 2) _color = 10 -- push
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
	assert(_frame ~= nil)
	_flip = _flip or false
	_flip = _flip ~= _frame.flip_x

	local _offset_x = _frame.origin_x
	if _flip then
		_offset_x = _frame.spr_w*8 - _frame.origin_x
	end

	return _x - _offset_x, _y - _frame.origin_y
end

function make_absolute_box(_frame, _box, _x, _y, _flip)
	assert(_frame ~= nil)
	assert(_box ~= nil)
	_flip = _flip or false
	_flip = xor(_flip, _frame.flip_x)

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

function draw_frame(_frame, _x, _y, _flip)
	assert(_frame ~= nil)
	local _corner_x, _corner_y = get_frame_upperleft_corner(_frame, _x, _y, _flip)
	local _spr_flip_x = xor(_flip, _frame.flip_x) -- all the flipping argument thing is super messy. I need to clarify and rewrite this
	spr(_frame.spr, _corner_x, _corner_y, _frame.spr_w, _frame.spr_h, _spr_flip_x, _frame.flip_y)
end

function draw_frame_boxes(_frame, _x, _y, _flip)
	for _i, _b in ipairs(_frame.boxes) do
		local _abs_box = make_absolute_box(_frame, _b, _x, _y, _flip)
		draw_box(_abs_box, 0, 0, _frame.spr_w, false)
	end
end

function get_animation_extent(_animation)
	assert(_animation ~= nil)
	local _min_x, _min_y, _max_x, _max_y = 0,0,0,0
	local _pos_x, _pos_y = 0,0

	for _i, _f in ipairs(_animation) do
		_pos_x += _f.movement[1]
		_pos_y += _f.movement[2]
		_min_x = min(_pos_x, _min_x)
		_min_y = min(_pos_y, _min_y)
		_max_x = max(_pos_x, _max_x)
		_max_y = max(_pos_y, _max_y)
	end
	return _min_x, _min_y, _max_x, _max_y
end

function get_animation_movement(_animation, _start_frame, _end_frame)
	assert(_animation ~= nil)
	_start_frame = _start_frame or 0
	_end_frame = _end_frame or (#_animation - 1)

	local _x, _y = 0, 0
	for _i = _start_frame, _end_frame do
		local _f = _animation[_i+1]
		_x += _f.movement[1]
		_y += _f.movement[2]
	end
	return _x, _y
end

function make_animation_player()
	return {
		animation = nil,
		frame = 0,
		is_looping = false,
		is_playing = false,
		movement_x = 0,
		movement_y = 0
	}
end

function play_animation_player(_player, _animation, _loop, _start_frame)
	assert(_player ~= nil)
	assert(_animation ~= nil)
	_player.animation = _animation
	_player.frame = _start_frame or 0
	_player.is_looping = _loop
	_player.is_playing = true
	_player.movement_x = _player.animation[_player.frame+1].movement[1]
	_player.movement_y = _player.animation[_player.frame+1].movement[2]
end

function stop_animation_player(_player)
	assert(_player ~= nil)
	_player.is_playing = false
end

function update_animation_player(_player)
	assert(_player ~= nil)
	if _player.animation ~= nil and _player.is_playing then
		_player.frame = (_player.frame + 1)
		if _player.frame >= #_player.animation then
			if _player.is_looping then
				_player.frame = 0
			else
				_player.is_playing = false
				_player.frame -= 1
			end
		end

		-- add movement
		if _player.is_playing then
			_player.movement_x += _player.animation[_player.frame+1].movement[1]
			_player.movement_y += _player.animation[_player.frame+1].movement[2]
		end
	end
end

function poll_animation_player_movement(_player)
	assert(_player ~= nil)
	local _x, _y = _player.movement_x, _player.movement_y
	_player.movement_x = 0
	_player.movement_y = 0
	return _x, _y
end

function draw_animation_player(_player, _x, _y, _flip)
	assert(_player ~= nil)
	if _player.animation ~= nil then
		local _animation_frame = _player.animation[_player.frame+1]
		local _game_frame = frames[_animation_frame.frame+1]
		draw_frame(_game_frame, _x, _y, _flip)
	end 
end
