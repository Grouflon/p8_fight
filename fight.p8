pico-8 cartridge // http://www.pico-8.com
version 38
__lua__
#include lib/math.lua
#include lib/log.lua
#include frame.lua
#include data.lua
#include game.lua

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000008888000000000800000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000800ff000000ff0080000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000f77000ff7f7f080000000000000000000000000000000000000000
0808800080888000088880008008800080888000080880000808800080888000000000000f777f00077777f80000000000000000000000000000000000000000
808ff000080ff000800ff000088ff000080ff000808ff000808ff000080ff000000000000ff77f00077777f80000000000000000000000000000000000000000
000f0000000f0000000f0000000f0000000f0000000f0000000f0000000f00000000000000777700007ff0000000000000000000000000000000000000000000
00f7f00000f7000000f770f000f77fff00f7000000f70000000f7000000f70000000000000f77000000000000000000000000000000000000000000000000000
0f777f000f77f0000f777f000f7770000f77f0000f77f0000077770000f777ff0000000000f00000000000000000000000000000000000000000000000000000
0fff7f000f777f000f7770000f7770000f7770000f777f0000f777f00f077700000f000008088000000000000000000000000000000000000000000000000000
0077700000ff7f0000ff70000ff7700000ff70000ff77f000f0777700f077777777f0000808ff000000000000000000000000000000000000000000000000000
0077700000777000007770000077700000777000007770000f0770770000777000000000007ff7ff000000000000000000000000000000000000000000000000
0070700000707000007070000070700000707000007770000007077000007000000000000f777700ff0000000000000000000000000000000000000000000000
0070700000707000007070000070700000707000000770000007f70000007000000000000f077777000000000000000000000000000000000000000000000000
00707000007070000070700000707000007007000007700000070f00000070000000000000777777770000000000000000000000000000000000000000000000
0070700000707000007070000070700007700700000700000007000000007000000000000007ff07777f00000000000000000000000000000000000000000000
0ff0ff000ff0ff000ff0ff000ff0ff000f000ff0000ff000000ff0000000ff00000000000000000007f000000000000000000000000000000000000000000000
