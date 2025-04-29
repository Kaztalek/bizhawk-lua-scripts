-- "pop_levitate.lua"
memory.usememorydomain("WRAM")

local ptr_princess = 0x4c6
local offset_y_vel = 0xe

while true do
    local princess_base = memory.read_u16_le(ptr_princess)
    if input.get().C then
        memory.write_s16_le(princess_base + offset_y_vel, -7)
    end
    emu.frameadvance()
end
