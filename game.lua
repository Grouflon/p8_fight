poke(0x5F5C, 255) -- kill autofire

function sm_set_state(_sm, _state)
	add(_sm.transition_queue, _state)
end
function sm_update(_sm)
	sm_dequeue_transitions(_sm)
	if _sm[_sm.state] ~= nil and _sm[_sm.state].update ~= nil then
		_sm[_sm.state].update()
	end
	sm_dequeue_transitions(_sm)
end
function sm_dequeue_transitions(_sm)
	for state in all(_sm.transition_queue) do
		if _sm.state == state then
			return
		end

		if _sm[_sm.state] ~= nil and _sm[_sm.state].exit ~= nil then
			_sm[_sm.state].exit()
		end
		_sm.state = state
		if _sm[_sm.state] ~= nil and _sm[_sm.state].enter ~= nil then
			_sm[_sm.state].enter()
		end
	end
	_sm.transition_queue = {}
end

animation_player = make_animation_player()
sub_animation_player = make_animation_player()
ground_height = 50
player_pos = vec2(50, ground_height)
player_flip = false
next_attack_type = ""
has_air_attacked = false
crouch = false
player_sm = {
	idle = {
		enter = function()
			play_animation_player(animation_player, animations.idle, true)
			if btn(3) then
				play_animation_player(animation_player, animations.crouch, true)
			end
		end,
		update = function()

			local direction = 0
			if btn(0) then
				direction = direction - 1
			end
			if btn(1) then
				direction = direction + 1
			end
			crouch = btn(3)
			if (crouch) direction = 0

			local speed = 1
			
			if direction ~= 0 then
				player_flip = direction < 0
				player_pos.x = player_pos.x + direction * speed
				if animation_player.animation ~= animations.walk then
					play_animation_player(animation_player, animations.walk, true)
				end
			else
				if crouch then
					if animation_player.animation ~= animations.crouch then
						play_animation_player(animation_player, animations.crouch, true)
					end
				else
					if animation_player.animation ~= animations.idle then
						play_animation_player(animation_player, animations.idle, true)
					end
				end
			end

			if btnp(4) then
				if crouch then
					next_attack_type = "crouch_punch"
				else
					next_attack_type = "punch"
				end
				sm_set_state(player_sm, "attack")
			end
			if btnp(5) then
				if crouch then
					next_attack_type = "crouch_kick"
				else
					next_attack_type = "kick"
				end
				sm_set_state(player_sm, "attack")
			end
			if btn(2) then
				jump_direction = direction
				sm_set_state(player_sm, "jump")
			end
		end,
		exit = function()
			crouch = false
		end,
	},
	attack = {
		enter = function()
			animation = animations[next_attack_type]
			play_animation_player(animation_player, animation, false)
		end,
		update = function()
			if (not animation_player.is_playing) then
				sm_set_state(player_sm, "idle")
			end
		end,
		exit = function()
		end,
	},
	jump = {
		enter = function()
			play_animation_player(animation_player, animations.jump, true)
		end,
		update = function()

			if not has_air_attacked then
				if btnp(4) then
					play_animation_player(sub_animation_player, animations.jump_punch, false)
					has_air_attacked = true
				end
				if btnp(5) then
					play_animation_player(sub_animation_player, animations.jump_kick, true)
					has_air_attacked = true
				end
			end
			local _jump_movement_x, _jump_movement_y = poll_animation_player_movement(animation_player)
			player_pos += vec2(_jump_movement_x*jump_direction, _jump_movement_y)

			if player_pos.y >= ground_height and animation_player.frame > 10 then
				player_pos.y = ground_height
				sm_set_state(player_sm, "idle")
			end
		end,
		exit = function()
			has_air_attacked = false
			stop_animation_player(sub_animation_player)
		end,
	},
	state = "",
	transition_queue = {},
}
sm_set_state(player_sm, "idle")

function _update()
	sm_update(player_sm)
end

function _draw()
	cls(0)

	if has_air_attacked then
		draw_animation_player(sub_animation_player, player_pos.x, player_pos.y, player_flip)
	else
		draw_animation_player(animation_player, player_pos.x, player_pos.y, player_flip)
	end
	update_animation_player(animation_player)
	update_animation_player(sub_animation_player)
end