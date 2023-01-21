poke(0x5F5C, 255) -- kill autofire

-- GLOBAL
ground_height = 64
stage_margin = 2
start_offset = 20

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
		sm = make_sm(player_sm_definition)
	}
end

player_sm_definition = {
	idle = {
		enter = function(_player)
			play_animation_player(_player.animation_player, animations.idle, true)
			if btn(3, _player.id) then
				play_animation_player(_player.animation_player, animations.crouch, true)
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
					play_animation_player(_player.animation_player, animations.walk, true)
				end
			else
				if _player.crouch then
					if _player.animation_player.animation ~= animations.crouch then
						play_animation_player(_player.animation_player, animations.crouch, true)
					end
				else
					if _player.animation_player.animation ~= animations.idle then
						play_animation_player(_player.animation_player, animations.idle, true)
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
			local _animation = animations[_player.next_attack_type]
			play_animation_player(_player.animation_player, _animation, false)
		end,
		update = function(_player)
			if (not _player.animation_player.is_playing) then
				sm_set_state(_player.sm, "idle")
			end
		end,
		exit = function(_player)
		end,
	},
	jump = {
		enter = function(_player)
			play_animation_player(_player.animation_player, animations.jump, false)
			_player.is_jumping = true
		end,
		update = function(_player)

			if not _player.has_air_attacked then
				if btnp(4, _player.id) then
					play_animation_player(_player.sub_animation_player, animations.jump_punch, false)
					_player.drawn_animation_player = _player.sub_animation_player
					_player.has_air_attacked = true
				end
				if btnp(5, _player.id) then
					play_animation_player(_player.sub_animation_player, animations.jump_kick, true)
					_player.drawn_animation_player = _player.sub_animation_player
					_player.has_air_attacked = true
				end
			end
			local _jump_movement_x, _jump_movement_y = poll_animation_player_movement(_player.animation_player)
			_player.pos += vec2(_jump_movement_x*_player.jump_direction, _jump_movement_y)

			if _player.pos.y >= ground_height and _player.animation_player.frame > 10 then
				_player.pos.y = ground_height
				sm_set_state(_player.sm, "idle")
			end
		end,
		exit = function(_player)
			_player.has_air_attacked = false
			_player.is_jumping = false
			_player.drawn_animation_player = _player.animation_player
			stop_animation_player(_player.sub_animation_player)
		end,
	},
}

function update_players_flip(_players)
	local _bounds = {{ 9999, -9999 }, { 9999, -9999 }}

	-- CALCULATE BOUNDS FOR EACH PLAYER
	for _i = 1, 2 do
		local _p = players[_i]
		local _frame = player_get_current_frame(_p)
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

function player_get_current_frame(_player)
	local _animation_frame = _player.drawn_animation_player.animation[_player.drawn_animation_player.frame+1]
	return frames[_animation_frame.frame+1]
end

function player_start(_player)
	_player.drawn_animation_player = _player.animation_player
	sm_set_state(_player.sm, "idle")
end

function player_update(_player)
	sm_update(_player.sm, _player)
end

function player_draw(_player)
	draw_animation_player(_player.drawn_animation_player, _player.pos.x, _player.pos.y, _player.flip_x)
end
function player_post_update(_player)
	update_animation_player(_player.animation_player)
	update_animation_player(_player.sub_animation_player)
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

		local _p1_frame = player_get_current_frame(player1)
		local _p2_frame = player_get_current_frame(player2)

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
				if _b1.type == 2 then
					_boxes[1] = make_absolute_box(_p1_frame, _b1, player1.pos.x, player1.pos.y, player1.flip_x)
					local _correction1 = keep_in_stage(_boxes[1])
					if (_correction1 ~= 0) _corrected = true
					player1.pos.x += _correction1
					_boxes[1].min_x += _correction1
					_boxes[1].max_x += _correction1
					for _k, _b2 in ipairs(_p2_frame.boxes) do
						if _b2.type == 2 then
							_boxes[2] = make_absolute_box(_p2_frame, _b2, player2.pos.x, player2.pos.y, player2.flip_x)
							local _correction2 = keep_in_stage(_boxes[2])
							if (_correction2 ~= 0) _corrected = true
							player2.pos.x += _correction2
							_boxes[2].min_x += _correction2
							_boxes[2].max_x += _correction2

							if collision.AABB_AABB(_boxes[1].min_x, _boxes[1].min_y, _boxes[1].max_x, _boxes[1].max_y, _boxes[2].min_x, _boxes[2].min_y, _boxes[2].max_x, _boxes[2].max_y) then

								local _push_directions = { 0, 0 }
								local _leftmost_box = 0
								local _rightmost_box = 0
								if (_boxes[1].min_x < _boxes[2].min_x) _push_directions = { -1, 1 }
								if (_boxes[1].max_x > _boxes[2].max_x) _push_directions = { 1, -1 }
								if (_push_directions[1] == 0) _push_directions = { bool_to_sign(player1.flip_x), bool_to_sign(player2.flip_x) }

								if (_push_directions[1] == _push_directions[2]) _push_directions = { -1, 1 } -- this is arbitrary, we should see that this never happens

								if (_push_directions[1] < 0) _leftmost_box = 1 _rightmost_box = 2 else _leftmost_box = 2 _rightmost_box = 1

								local _penetration = _boxes[_leftmost_box].max_x - _boxes[_rightmost_box].min_x
								player1.pos.x +=  _push_directions[1] * _penetration * 0.5
								player2.pos.x +=  _push_directions[2] * _penetration * 0.5

								_boxes[1] = make_absolute_box(_p1_frame, _b1, player1.pos.x, player1.pos.y, player1.flip_x)
								_boxes[2] = make_absolute_box(_p2_frame, _b1, player2.pos.x, player2.pos.y, player2.flip_x)

								_correction1 = keep_in_stage(_boxes[1])
								_correction2 = keep_in_stage(_boxes[2])
								player1.pos.x += _correction1 + _correction2
								player2.pos.x += _correction1 + _correction2

								_corrected = true
							end
						end
					end
				end
			end
			if (not _corrected) break
		end

		update_players_flip(players)
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

	local _p1_frame = player_get_current_frame(player1)
	local _p2_frame = player_get_current_frame(player2)
	--draw_frame_boxes(_p1_frame, player1.pos.x, player1.pos.y, player1.flip_x)
	--draw_frame_boxes(_p2_frame, player2.pos.x, player2.pos.y, player2.flip_x)

	if (player1 ~= nil) player_post_update(player1)
	if (player2 ~= nil) player_post_update(player2)
end
