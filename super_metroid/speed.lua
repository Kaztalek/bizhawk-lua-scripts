-- "SMspeed.lua"

local hspeed_addr = 0xb42
local hspeed_sub_addr = 0xb44
local vspeed_addr = 0xb2e
local vspeed_sub_addr = 0xb2c

local y_offset = 14
local x = 0
local y = 5 * y_offset

while true do
    local hspeed = 'h speed: ' .. memory.readbyte(hspeed_addr) .. '.' .. memory.read_u16_le(hspeed_sub_addr)
    local vspeed = 'v speed: ' .. memory.readbyte(vspeed_addr) .. '.' .. memory.read_u16_le(vspeed_sub_addr)

    gui.text(x, y, hspeed)
    gui.text(x, y + y_offset, vspeed)

    emu.frameadvance()
end
