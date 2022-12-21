-- coordinates origin for every position/sprite/hitbox is upper left
function make_box(_x, _y, _w, _h)
	return {
		min_x = _x,
		min_y = _y,
		max_x = _x + _w,
		max_y = _y + _h,
	}
end

function draw_box(_box, _x, _y, _w, _flip, _color)
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

function make_frame(_spr, _spr_w, _spr_h, _flip_x, _flip_y, _origin_x, _origin_y, _hitboxes, _hurtboxes)
	return {
    	spr = _spr,
    	spr_w = _spr_w,
    	spr_h = _spr_h,
    	flip_x = _flip_x,
    	flip_y = _flip_y,
    	origin_x = _origin_x,
    	origin_y = _origin_y,
    	hitboxes = _hitboxes or {},
    	hurtboxes = _hurtboxes or {},
  	}
end

function draw_frame(_frame, _x, _y, _flip, _draw_boxes)

	_flip = _flip or false
	_flip = _flip ~= _frame.flip_x

	--print(""..tostring(_flip).."/"..tostring(_frame.flip_x).."/"..tostring(bxor(bool_to_int(_flip),bool_to_int(_frame.flip_x))))
	--_flip = _flip ~_frame.flip_x

	local offset_x = _frame.origin_x
	if _flip then
		offset_x = _frame.spr_w*8 - _frame.origin_x
	end

	local x = _x - offset_x
	local y = _y - _frame.origin_y

	spr(_frame.spr, x, y, _frame.spr_w, _frame.spr_h, _flip, _frame.flip_y)

	if _draw_boxes then
		for _i, _b in ipairs(_frame.hurtboxes) do
			draw_box(_b, x, y, _frame.spr_w, _flip, 11)
		end

		for _i, _b in ipairs(_frame.hitboxes) do
			draw_box(_b, x, y, _frame.spr_w, _flip, 8)
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
