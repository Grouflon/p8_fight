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
		if _sm.state == state then
			return
		end

		if _sm.definition[_sm.state] ~= nil and _sm.definition[_sm.state].exit ~= nil then
			_sm.definition[_sm.state].exit(_data)
		end
		_sm.state = state
		if _sm.definition[_sm.state] ~= nil and _sm.definition[_sm.state].enter ~= nil then
			_sm.definition[_sm.state].enter(_data)
		end
	end
	_sm.transition_queue = {}
end