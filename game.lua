poke(0x5F5C, 255) -- kill autofire

-- GLOBAL
ground_height = 64
stage_margin = 2
start_offset = 20

-- BAKE
for _key, _animation in pairs(animations) do
	animation_bake_data(_animation)
end

-- HIT
hit_animation = { 128, 128, 129, 129, 130, 130, 130 }
hits = {}

function hits_add(_hits, _type, _x, _y, _flip_x)
	if (_type == 0) _flip_x = not _flip_x
	local _x_offset = 0
	if (_flip_x) _x_offset = -8
	add(_hits, {
		type = _type,
		x = _x + _x_offset,
		y = _y - 4,
		flip = _flip_x,
		frame = 0,
	})
end

function hits_draw(_hits)
	for _h in all(_hits) do
		if (_h.type == 0) pal(12, 9)
		spr(hit_animation[_h.frame+1], _h.x, _h.y, 1, 1, _h.flip)
		pal()
		_h.frame += 1
		if _h.frame >= #hit_animation then
			del(_hits, _h)
		end
	end
end

-- PLAYER
function make_player(_id, _x)
	return {
		id = _id,
		animation_player = make_animation_player(),
		sub_animation_player = make_animation_player(),
		drawn_animation_player = nil,
		pos = vec2(_x, ground_height),
		flip_x = false,
		next_attack_type = "",
		jump_direction = 0,
		is_jumping = false,
		has_air_attacked = false,
		crouch = false,
		current_hit_id = -1,
		next_hit_id = -1,
		current_inflicted_hit = nil,
		being_hit_time = 0,
		freeze_count = 0,
		sm = make_sm(player_sm_definition),
	}
end

player_sm_definition = {
	idle = {
		enter = function(_player)
			animation_player_play(_player.animation_player, animations.idle, true)
			if btn(3, _player.id) then
				animation_player_play(_player.animation_player, animations.crouch, true)
			end
		end,
		update = function(_player)

			local _direction = 0
			if btn(0, _player.id) then
				_direction = _direction - 1
			end
			if btn(1, _player.id) then
				_direction = _direction + 1
			end
			_player.crouch = btn(3, _player.id)
			if (_player.crouch) _direction = 0

			local _speed = 1
			if (_direction == bool_to_sign(_player.flip_x)) _speed = 0.75
			
			if _direction ~= 0 then
				--_player.flip_x = _direction < 0
				_player.pos.x = _player.pos.x + _direction * _speed
				if _player.animation_player.animation ~= animations.walk then
					animation_player_play(_player.animation_player, animations.walk, true)
				end
			else
				if _player.crouch then
					if _player.animation_player.animation ~= animations.crouch then
						animation_player_play(_player.animation_player, animations.crouch, true)
					end
				else
					if _player.animation_player.animation ~= animations.idle then
						animation_player_play(_player.animation_player, animations.idle, true)
					end
				end
			end

			if btnp(4, _player.id) then
				if _player.crouch then
					_player.next_attack_type = "crouch_punch"
				else
					_player.next_attack_type = "punch"
				end
				sm_set_state(_player.sm, "attack")
			end
			if btnp(5, _player.id) then
				if _player.crouch then
					_player.next_attack_type = "crouch_kick"
				else
					_player.next_attack_type = "kick"
				end
				sm_set_state(_player.sm, "attack")
			end
			if btn(2, _player.id) then
				_player.jump_direction = _direction
				sm_set_state(_player.sm, "jump")
			end
		end,
		exit = function(_player)
			_player.crouch = false
		end,
	},
	attack = {
		enter = function(_player)
			_player.current_hit_id = 0
			_player.next_hit_id = 0
			local _animation = animations[_player.next_attack_type]
			animation_player_play(_player.animation_player, _animation, false)
		end,
		update = function(_player)
			if (not _player.animation_player.is_playing) then
				sm_set_state(_player.sm, "idle")
			end

			local _frame = player_get_current_animation_frame(_player)
			if (_frame.id ~= nil) then
				_player.current_hit_id = _frame.id
				_player.next_hit_id = _frame.id
			end

		end,
		exit = function(_player)
			_player.current_hit_id = -1
			_player.next_hit_id = -1
		end,
	},
	jump = {
		enter = function(_player)
			_player.current_hit_id = 0
			_player.next_hit_id = 0
			animation_player_play(_player.animation_player, animations.jump, false, 0)
			_player.is_jumping = true
		end,
		update = function(_player)

			if not _player.has_air_attacked then
				if btnp(4, _player.id) then
					animation_player_play(_player.sub_animation_player, animations.jump_punch, false)
					_player.drawn_animation_player = _player.sub_animation_player
					_player.has_air_attacked = true
				end
				if btnp(5, _player.id) then
					animation_player_play(_player.sub_animation_player, animations.jump_kick, true)
					_player.drawn_animation_player = _player.sub_animation_player
					_player.has_air_attacked = true
				end
			end
			local _jump_movement_x, _jump_movement_y = animation_player_poll_movement(_player.animation_player)
			_player.pos += vec2(_jump_movement_x*_player.jump_direction, _jump_movement_y)

			if _player.pos.y >= ground_height and _player.animation_player.frame > 10 then
				_player.pos.y = ground_height
				sm_set_state(_player.sm, "idle")
			end
		end,
		exit = function(_player)
			_player.current_hit_id = -1
			_player.next_hit_id = -1
			_player.has_air_attacked = false
			_player.is_jumping = false
			_player.drawn_animation_player = _player.animation_player
			animation_player_stop(_player.sub_animation_player)
		end,
	},
	hit = {
		can_reenter = true,
		enter = function(_player)
			_player.being_hit_time = 0
			local _h = _player.current_inflicted_hit
			local _hit_animation = hittype_to_animation(_h.type)
			local _playrate = max(#_hit_animation.frames / _h.hitstun, 1)
			--log(_playrate)
			animation_player_play(_player.animation_player, _hit_animation, false, 0, _playrate)
		end,
		update = function(_player)
			local _m_x, _m_y = animation_player_poll_movement(_player.animation_player)
			local _scale_x = _player.current_inflicted_hit.pushback*-1 / _player.animation_player.animation.movement[1]
			_player.pos.x += _m_x * _scale_x* bool_to_sign(_player.flip_x)*-1

			_player.being_hit_time += 1

			if _player.being_hit_time > _player.current_inflicted_hit.hitstun then
				sm_set_state(_player.sm, "idle")
			end
		end,
		exit = function(_player)
		end,
	},
}

function player_get_current_animation_frame(_player)
	local _animation_frame = animation_player_get_current_animation_frame(_player.drawn_animation_player)
	return frames[_animation_frame.frame+1]
end

function player_get_current_hit(_player)
	local _animation = _player.drawn_animation_player.animation

	if (_animation.hits) == nil or (_animation.hits[_player.current_hit_id+1] == nil) then
		return { hitstun = 3, pushback = 3, type = 0, hitstop = 4 }
	end

	return _animation.hits[_player.current_hit_id+1]
end

function player_start(_player)
	_player.drawn_animation_player = _player.animation_player
	sm_set_state(_player.sm, "idle")
end

function player_update(_player)
	if _player.freeze_count > 0 then
		_player.freeze_count -= 1
		sm_dequeue_transitions(_player.sm, _player)
	else
		sm_update(_player.sm, _player)
	end
end

function player_draw(_player)
	animation_player_draw(_player.drawn_animation_player, _player.pos.x, _player.pos.y, _player.flip_x)
end
function player_post_update(_player)
	animation_player_update(_player.animation_player)
	animation_player_update(_player.sub_animation_player)
end

function player_resolve_hit(_player, _hit)
	_player.next_hit_id += 1
	_player.freeze_count = _hit.hitstop
end

function player_resolve_being_hit(_player, _hit, _hit_x, _hit_y)
	_player.current_inflicted_hit = _hit
	_player.freeze_count = _hit.hitstop
	sm_set_state(_player.sm, "hit")

	hits_add(hits, 0, _hit_x, _hit_y, _player.flip_x)
	sfx(0)
end


function resolve_players_flip(_players)
	local _bounds = {{ 9999, -9999 }, { 9999, -9999 }}

	-- CALCULATE BOUNDS FOR EACH PLAYER
	for _i = 1, 2 do
		local _p = players[_i]
		local _frame = player_get_current_animation_frame(_p)
		for _j, _b in ipairs(_frame.boxes) do
			if _b.type == 2 then
				local _abs_box = make_absolute_box(_frame, _b, _p.pos.x, _p.pos.y, _p.flip_x)
				_bounds[_i][1] = min(_bounds[_i][1], _abs_box.min_x)
				_bounds[_i][2] = max(_bounds[_i][2], _abs_box.max_x)
			end
		end
	end

	-- RESOLVE FLIPS
	for _i = 0, 1 do
		local _p_index = _i+1
		local _other_p_index = ((_i+1)%2)+1
		local _p = _players[_p_index]
		if not _p.is_jumping then
			if _bounds[_p_index][1] < _bounds[_other_p_index][1] - 1 then
				_p.flip_x = false
			elseif _bounds[_p_index][2] > _bounds[_other_p_index][2] + 1 then
				_p.flip_x = true
			end
		end
	end
end

function resolve_players_push(_players)

	local _p1 = _players[1]
	local _p2 = _players[2]
	local _p1_frame = player_get_current_animation_frame(_p1)
	local _p2_frame = player_get_current_animation_frame(_p2)

	function keep_in_stage(_abs_box)
		local _correction = 0
		if _abs_box.min_x < stage_margin then
			_correction += stage_margin-_abs_box.min_x
		end
		if _abs_box.max_x >= 128 - stage_margin then
			_correction += 128 - stage_margin-_abs_box.max_x
		end
		return _correction
	end

	for _i = 0,3 do
		local _corrected = false
		local _boxes = { nil, nil }
		for _j, _b1 in ipairs(_p1_frame.boxes) do
			if _b1.type == BOXTYPE_PUSH then
				_boxes[1] = make_absolute_box(_p1_frame, _b1, _p1.pos.x, _p1.pos.y, _p1.flip_x)
				local _correction1 = keep_in_stage(_boxes[1])
				if (_correction1 ~= 0) _corrected = true
				_p1.pos.x += _correction1
				_boxes[1].min_x += _correction1
				_boxes[1].max_x += _correction1
				for _k, _b2 in ipairs(_p2_frame.boxes) do
					if _b2.type == BOXTYPE_PUSH then
						_boxes[2] = make_absolute_box(_p2_frame, _b2, _p2.pos.x, _p2.pos.y, _p2.flip_x)
						local _correction2 = keep_in_stage(_boxes[2])
						if (_correction2 ~= 0) _corrected = true
						_p2.pos.x += _correction2
						_boxes[2].min_x += _correction2
						_boxes[2].max_x += _correction2

						if collision.AABB_AABB(_boxes[1].min_x, _boxes[1].min_y, _boxes[1].max_x, _boxes[1].max_y, _boxes[2].min_x, _boxes[2].min_y, _boxes[2].max_x, _boxes[2].max_y) then

							local _push_directions = { 0, 0 }
							local _leftmost_box = 0
							local _rightmost_box = 0
							if (_boxes[1].min_x < _boxes[2].min_x) _push_directions = { -1, 1 }
							if (_boxes[1].max_x > _boxes[2].max_x) _push_directions = { 1, -1 }
							if (_push_directions[1] == 0) _push_directions = { bool_to_sign(_p1.flip_x), bool_to_sign(_p2.flip_x) }

							if (_push_directions[1] == _push_directions[2]) _push_directions = { -1, 1 } -- this is arbitrary, we should see that this never happens

							if (_push_directions[1] < 0) _leftmost_box = 1 _rightmost_box = 2 else _leftmost_box = 2 _rightmost_box = 1

							local _penetration = _boxes[_leftmost_box].max_x - _boxes[_rightmost_box].min_x
							_p1.pos.x +=  _push_directions[1] * _penetration * 0.5
							_p2.pos.x +=  _push_directions[2] * _penetration * 0.5

							_boxes[1] = make_absolute_box(_p1_frame, _b1, _p1.pos.x, _p1.pos.y, _p1.flip_x)
							_boxes[2] = make_absolute_box(_p2_frame, _b1, _p2.pos.x, _p2.pos.y, _p2.flip_x)

							_correction1 = keep_in_stage(_boxes[1])
							_correction2 = keep_in_stage(_boxes[2])
							_p1.pos.x += _correction1 + _correction2
							_p2.pos.x += _correction1 + _correction2

							_corrected = true
						end
					end
				end
			end
		end
		if (not _corrected) break
	end
end

function resolve_players_hit(_players)

	local _p1 = _players[1]
	local _p2 = _players[2]
	local _p1_frame = player_get_current_animation_frame(_p1)
	local _p2_frame = player_get_current_animation_frame(_p2)
	local _p1_to_p2_hit = nil
	local _p2_to_p1_hit = nil
	local _hit_position_x, _hit_position_y = 0, 0


	for _i, _b1 in ipairs(_p1_frame.boxes) do
		local _p1_box = make_absolute_box(_p1_frame, _b1, _p1.pos.x, _p1.pos.y, _p1.flip_x)
		for _j, _b2 in ipairs(_p2_frame.boxes) do
			local _p2_box = make_absolute_box(_p2_frame, _b2, _p2.pos.x, _p2.pos.y, _p2.flip_x)

			if _p1_to_p2_hit == nil and _b1.type == BOXTYPE_HIT and _b2.type == BOXTYPE_HURT then
				if collision.AABB_AABB(_p1_box.min_x, _p1_box.min_y, _p1_box.max_x, _p1_box.max_y, _p2_box.min_x, _p2_box.min_y, _p2_box.max_x, _p2_box.max_y) then
					if _p1.current_hit_id == _p1.next_hit_id then
						_p1_to_p2_hit = player_get_current_hit(_p1)
						_hit_position_x, _hit_position_y = get_AABB_intersection(_p1_box.min_x, _p1_box.min_y, _p1_box.max_x, _p1_box.max_y, _p2_box.min_x, _p2_box.min_y, _p2_box.max_x, _p2_box.max_y)
					end
				end
			elseif _p2_to_p1_hit == nil and _b2.type == BOXTYPE_HIT and _b1.type == BOXTYPE_HURT then
				if collision.AABB_AABB(_p1_box.min_x, _p1_box.min_y, _p1_box.max_x, _p1_box.max_y, _p2_box.min_x, _p2_box.min_y, _p2_box.max_x, _p2_box.max_y) then
					if _p2.current_hit_id == _p2.next_hit_id then
						_p2_to_p1_hit = player_get_current_hit(_p2)
						_hit_position_x, _hit_position_y = get_AABB_intersection(_p1_box.min_x, _p1_box.min_y, _p1_box.max_x, _p1_box.max_y, _p2_box.min_x, _p2_box.min_y, _p2_box.max_x, _p2_box.max_y)
					end
				end
			end
		end
	end

	if _p1_to_p2_hit ~= nil then
		player_resolve_hit(_p1, _p1_to_p2_hit)
		player_resolve_being_hit(_p2, _p1_to_p2_hit, _hit_position_x, _hit_position_y)
	end
	if _p2_to_p1_hit ~= nil then
		player_resolve_hit(_p2, _p2_to_p1_hit)
		player_resolve_being_hit(_p1, _p2_to_p1_hit, _hit_position_x, _hit_position_y)
	end

end

-- GAME
player1 = make_player(1, 64-start_offset)
player2 = make_player(0, 64+start_offset)
players = { player1, player2 }

if (player1 ~= nil) player_start(player1)
if (player2 ~= nil) player_start(player2)

function _update()
	if (player1 ~= nil) player_update(player1)
	if (player2 ~= nil) player_update(player2)

	if (player1 ~= nil and player2 ~= nil) then
		resolve_players_push(players)
		resolve_players_flip(players)
		resolve_players_hit(players)
	end
end

function _draw()
	cls(13)
	rectfill(0, 0, 128, ground_height - 5, 1)

	srand(9)
	for _i = 1, 25 do
		local _x = flr(rnd(128))
		local _y = flr(rnd(ground_height-13))
		pset(_x, _y, 10)
	end

	circfill(102, 15, 7, 10)
	circfill(100, 14, 5, 1)

	if (player1 ~= nil) player_draw(player1)
	if (player2 ~= nil) player_draw(player2)

	local _p1_frame = player_get_current_animation_frame(player1)
	local _p2_frame = player_get_current_animation_frame(player2)
	--draw_frame_boxes(_p1_frame, player1.pos.x, player1.pos.y, player1.flip_x)
	--draw_frame_boxes(_p2_frame, player2.pos.x, player2.pos.y, player2.flip_x)

	if (player1 ~= nil and player1.freeze_count <= 0) player_post_update(player1)
	if (player2 ~= nil and player2.freeze_count <= 0) player_post_update(player2)

	hits_draw(hits)
end
