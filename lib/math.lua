-- math.lua

-- vec2
vec2_mt = {}
vec2_mt.__index = vec2_mt

function vec2_mt:set(_x, _y)
  self.x = _x
  self.y = _y
end

function vec2_mt:__add(_v)
  return vec2(self.x + _v.x, self.y + _v.y)
end

function vec2_mt:__sub(_v)
  return vec2(self.x - _v.x, self.y - _v.y)
end

function vec2_mt:__mul(_s)
  return vec2(self.x * _s, self.y * _s)
end

function vec2_mt:dot(_v)
  return self.x * _v.x + self.y * _v.y
end

function vec2_mt:len()
  return sqrt(self.x * self.x + self.y * self.y)
end

function vec2_mt:normalized()
  local _len = self:len()
  if _len > 0.0 then
    return vec2(self.x / _len, self.y / _len)
  else
    return vec2()
  end
end

function vec2_mt:flr()
  return vec2(flr(self.x), flr(self.y))
end

function vec2_mt:is_zero(_threshold)
  _threshold = _threshold or 0.01
  return abs(self.x) <= _threshold and abs(self.y) <= _threshold
end

function vec2_mt:copy()
  return vec2(self.x, self.y)
end

function vec2_mt:__tostring()
  return "{"..self.x..","..self.y.."}"
end

function vec2_mt.lerp(_a, _b, _t)
  return vec2(
    math.lerp(_a.x, _b.x, _t),
    math.lerp(_a.y, _b.y, _t)
  )
end

function vec2(_x, _y)
  local _v = {
    x = _x or 0,
    y = _y or 0
  }
  setmetatable(_v, vec2_mt)
  return _v
end

-- math
function clamp01(_v)
  return mid(0.0, 1.0, _v)
end

function lerp(_a, _b, _t)
  return _a + (_b - _a) * _t
end

function round(_x)
  local _flr = flr(_x)
  local _rmd = _x - _flr
  if _rmd > 0.5 then
    return ceil(_x)
  else
    return _flr
  end
end

function bool_to_int(_b)
  if _b then
    return 1
  else
    return 0
  end
end

function bool_to_sign(_b)
  if _b then
    return 1
  else
    return -1
  end
end

function xor(_a, _b)
  return (_a or _b) and not (_a and _b)
end

function positive_mod(_value, _mod)
  return ((_value%_mod)+_mod)%_mod
end

D2P = 1 / 360.0 -- degrees to Pico-8 angle unit
P2D = 360.0 -- Pico-8 angle unit to degrees

-- collision
collision = {}

function collision.AABB_AABB(_x_min_A, _y_min_A, _x_max_A, _y_max_A, _x_min_B, _y_min_B, _x_max_B, _y_max_B)
  return not (
     _x_max_A <= _x_min_B
  or _y_max_A <= _y_min_B
  or _x_max_B <= _x_min_A
  or _y_max_B <= _y_min_A
  )
end

-- from https://stackoverflow.com/questions/563198/how-do-you-detect-where-two-line-segments-intersect
function collision.segment_segment(_p0_x, _p0_y, _p1_x, _p1_y, _p2_x, _p2_y, _p3_x, _p3_y)
  local _s1_x, _s1_y = _p1_x - _p0_x, _p1_y - _p0_y
  local _s2_x, _s2_y = _p3_x - _p2_x, _p3_y - _p2_y

  local _s = (-_s1_y * (_p0_x - _p2_x) + _s1_x * (_p0_y - _p2_y)) / (-_s2_x * _s1_y + _s1_x * _s2_y);
  local _t = ( _s2_x * (_p0_y - _p2_y) - _s2_y * (_p0_x - _p2_x)) / (-_s2_x * _s1_y + _s1_x * _s2_y);

  if _s >= 0 and _s <= 1 and _t >= 0 and _t <= 1 then
      return true, _p0_x + (_t * _s1_x), _p0_y + (_t * _s1_y)
    end

  return false
end

function collision.point_AABB(_x, _y, _x_min, _y_min, _x_max, _y_max)
  return not (
    _x < _x_min or _x > _x_max or
    _y < _y_min or _y > _y_max
  )
end

-- easing {}
easing = {}

function easing.linear(_t)
  return _t
end

function easing.quad_in(_t)
  return _t * _t
end

function easing.quad_out(_t)
  return -_t * (_t - 2.0)
end

function easing.quad_inout(_t)
  if _t <= 0.5 then
    return _t * _t * 2.0;
  else
    _t = _t - 1.0;
    return 1.0 - _t * _t * 2.0
  end
end

function easing.back_in(_t)
  return _t * _t * (2.70158 * _t - 1.70158)
end

function easing.back_out(_t)
  _t = _t - 1.0;
  return 1.0 - _t * _t * (-2.701580 * _t - 1.701580)
end

function easing.back_inout(_t)
  _t = _t * 2.0;

  if _t < 1.0 then
    return _t * _t * (2.70158 * _t - 1.70158) / 2.0
  else
  	_t = _t - 2.0
  	return (1.0 - _t * _t * (-2.70158 * _t - 1.70158)) / 2.0 + 0.5
  end
end
