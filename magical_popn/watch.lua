memory.usememorydomain("WRAM")

local ptr_princess = {0x4c6, "u16"}
local offset_x_pos = {0x4, "u16"}
local offset_x_subpixel = {0x6, "u16"}
local offset_y_pos = {0x8, "u16"}
local offset_y_subpixel = {0xa, "u16"}
local offset_x_vel = {0xc, "s16"}
local offset_y_vel = {0xe, "s16"}

local addr_health = {0x51a, "u8"}

local fn_list = {
    s8 = memory.read_s8,
    u8 = memory.read_u8,
    s16 = memory.read_s16_le,
    u16 = memory.read_u16_le,
    s24 = memory.read_s24_le,
    u24 = memory.read_u24_le,
    s32 = memory.read_s32_le,
    u32 = memory.read_u32_le,
    f = memory.readfloat
}
function read_addr(addr, base)
    return fn_list[addr[2]]((base or 0) + addr[1])
end

local text_height = 14
local text_x = 0
local text_y = text_height * 3
function s_print(label, value, line_no)
    gui.text(text_x, text_y + text_height * line_no, label .. ": " .. value)
end

while true do
    local princess_base = read_addr(ptr_princess)
    s_print("X", read_addr(offset_x_pos, princess_base), 0)
    s_print("X sub", read_addr(offset_x_subpixel, princess_base), 1)
    s_print("Y", read_addr(offset_y_pos, princess_base), 2)
    s_print("Y sub", read_addr(offset_y_subpixel, princess_base), 3)
    s_print("X vel", read_addr(offset_x_vel, princess_base), 4)
    s_print("Y vel", read_addr(offset_y_vel, princess_base), 5)
    s_print("Health", read_addr(addr_health), 6)
    emu.frameadvance()
end
