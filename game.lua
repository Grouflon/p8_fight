poke(0x5F5C, 255) -- kill autofire

w0 = 32
w1 = 10
h = 26

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
player_pos = vec2(50, 50)
player_flip = false
next_attack_type = ""
player_sm = {
	idle = {
		enter = function()
			play_animation(animation_player, animations.idle, true)
		end,
		update = function()

			local direction = 0
			if btn(0) then
				direction = direction - 1
			end
			if btn(1) then
				direction = direction + 1
			end

			local speed = 1
			
			if direction ~= 0 then
				player_flip = direction < 0
				player_pos.x = player_pos.x + direction * speed
				play_animation(animation_player, animations.walk, true)
			else
				play_animation(animation_player, animations.idle, true)
			end

			if btnp(4) then
				next_attack_type = "punch"
				sm_set_state(player_sm, "attack")
			end
			if btnp(5) then
				next_attack_type = "kick"
				sm_set_state(player_sm, "attack")
			end
			if btn(2) then
				jump_direction = direction
				sm_set_state(player_sm, "jump")
			end
		end,
		exit = function()
		end,
	},
	attack = {
		enter = function()
			animation = animations[next_attack_type]
			play_animation(animation_player, animation, false)
		end,
		update = function()
			if (animation_player.animation == nil) then
				sm_set_state(player_sm, "idle")
			end
		end,
		exit = function()
		end,
	},
	jump = {
		enter = function()
			play_animation(animation_player, animations.jump, true)

			jump = make_jump(player_pos.x, player_pos.y - 3, jump_direction*w0, jump_direction*w1, h)
			jump_t = 0
		end,
		update = function()

			if btnp(5) then
				play_animation(animation_player, animations.jump_kick, true)
			end

			local _t = jump_t / jump_duration

			player_pos = compute_jump_position(jump, _t)

			if _t >= 1 then
				player_pos = jump.p3:copy()
				player_pos.y = player_pos.y + 3
				jump = nil
				sm_set_state(player_sm, "idle")
			end
			jump_t = jump_t + 1
		end,
		exit = function()
		end,
	},
	state = "",
	transition_queue = {},
}
sm_set_state(player_sm, "idle")

jump = nil
jump_t = 0
jump_duration = 20
jump_direction = 0

function make_jump(_origin_x, _origin_y, _w0, _w1, _h)
	local o = vec2(_origin_x, _origin_y)
	return {
		p0 = o,
		p1 = o + vec2((_w0-_w1) * 0.5, -_h),
		p2 = o + vec2((_w0-_w1) * 0.5 + _w1, -_h),
		p3 = o + vec2(_w0, 0),
	}
end

function compute_jump_position(_jump, _t)

	function s(_t1, _t2, _t3, _p0, _p1, _p2, _p3)
		return _p0 + _t1*(-3*_p0+3*_p1) + _t2*(3*_p0-6*_p1+3*_p2) + _t3*(-_p0+3*_p1-3*_p2+_p3)
	end

	local t1 = _t
	local t2 = t1*t1
	local t3 = t2*t1
	local x = s(t1, t2, t3, _jump.p0.x, _jump.p1.x, _jump.p2.x, _jump.p3.x)
	local y = s(t1, t2, t3, _jump.p0.y, _jump.p1.y, _jump.p2.y, _jump.p3.y)
	return vec2(x, y)
end

function _update()
	sm_update(player_sm)

	
end

function _draw()
	cls(0)

	draw_animation(animation_player, player_pos.x, player_pos.y, player_flip)
	update_animation(animation_player)
end