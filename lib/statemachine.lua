function make_sm(_definition)
	assert(_definition ~= nil)
	return {
		definition = _definition,
		state = "",
		transition_queue = {},
	}
end

function sm_set_state(_sm, _state)
	add(_sm.transition_queue, _state)
end
function sm_update(_sm, _data)
	sm_dequeue_transitions(_sm, _data)
	if _sm.definition[_sm.state] ~= nil and _sm.definition[_sm.state].update ~= nil then
		_sm.definition[_sm.state].update(_data)
	end
	sm_dequeue_transitions(_sm, _data)
end
function sm_dequeue_transitions(_sm, _data)
	for state in all(_sm.transition_queue) do
		local _source_state_def = _sm.definition[_sm.state]
		local _target_state_def = _sm.definition[state]

		local _do_transition = _target_state_def ~= nil and ((_sm.state ~= state) or (_target_state_def.can_reenter))
		
		if _do_transition then
			if _source_state_def ~= nil and _source_state_def.exit ~= nil then
				_source_state_def.exit(_data)
			end
			_sm.state = state
			if _target_state_def.enter ~= nil then
				_sm.definition[_sm.state].enter(_data)
			end
		end
	end
	_sm.transition_queue = {}
end