poke(0x5F5C, 255) -- kill autofire

-- GLOBAL
ground_height = 64
start_offset = 20

-- PLAYER
function make_player(_id, _x)
	return {
		id = _id,
		animation_player = make_animation_player(),
		sub_animation_player = make_animation_player(),
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
					_player.has_air_attacked = true
				end
				if btnp(5, _player.id) then
					play_animation_player(_player.sub_animation_player, animations.jump_kick, true)
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
			stop_animation_player(_player.sub_animation_player)
		end,
	},
}

function player_update_flip(_self, _other)
	if not _self.is_jumping then
		_self.flip_x = _self.pos.x > _other.pos.x
	end
end

function player_start(_player)
	sm_set_state(_player.sm, "idle")
end

function player_update(_player, _other)
	sm_update(_player.sm, _player)
end

function player_draw(_player)

	if _player.has_air_attacked then
		draw_animation_player(_player.sub_animation_player, _player.pos.x, _player.pos.y, _player.flip_x)
	else
		draw_animation_player(_player.animation_player, _player.pos.x, _player.pos.y, _player.flip_x)
	end
end

function player_post_update(_player)
	update_animation_player(_player.animation_player)
	update_animation_player(_player.sub_animation_player)
end

-- GAME
player1 = make_player(1, 64-start_offset)
player2 = make_player(0, 64+start_offset)

if (player1 ~= nil) player_start(player1)
if (player2 ~= nil) player_start(player2)

function _update()
	if (player1 ~= nil) player_update(player1)
	if (player2 ~= nil) player_update(player2)

	if (player1 ~= nil and player2 ~= nil) then
		player_update_flip(player1, player2)
		player_update_flip(player2, player1)
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

	if (player1 ~= nil) player_post_update(player1)
	if (player2 ~= nil) player_post_update(player2)
end