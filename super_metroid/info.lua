-- "SMinfo.lua"
-- displays in game time and item percentage

local hours_addr = 0x09e0
local minutes_addr = 0x09de
local seconds_addr = 0x09dc
local frames_addr = 0x09da

local max_missiles_addr = 0x09c8
local max_super_missiles_addr = 0x09cc
local max_power_bombs_addr = 0x09d0
local max_health_addr = 0x09c4
local max_reserve_health_addr = 0x09d4
local collected_items_addr = 0x09a4
local collected_beams_addr = 0x09a8

local text_x = 72 -- string.len("60 fps  ") * char_width
local text_y = 0
local char_width = 9

function pad_2_digits(num)
    if num < 10 then
        return '0' .. num
    end
    return num
end

function get_time()
    local hours = memory.readbyte(hours_addr)
    local minutes = memory.readbyte(minutes_addr)
    local seconds = memory.readbyte(seconds_addr)
    local frames = memory.readbyte(frames_addr)
    return hours .. ':' ..
        pad_2_digits(minutes) .. ':' ..
        pad_2_digits(seconds) .. '.' ..
        pad_2_digits(frames)
end

function count_set_bits(n)
    local count = 0
    while n > 0 do
        count = count + (n & 1)
        n = n >> 1
    end
    return count
end

function get_percent()
    local max_missiles = memory.readbyte(max_missiles_addr)
    local max_super_missiles = memory.readbyte(max_super_missiles_addr)
    local max_power_bombs = memory.readbyte(max_power_bombs_addr)
    local max_health = memory.read_u16_le(max_health_addr)
    local max_reserve_health = memory.read_u16_le(max_reserve_health_addr)
    local collected_items = memory.read_u16_le(collected_items_addr)
    local collected_beams = memory.read_u16_le(collected_beams_addr)

    local missile_percent = max_missiles / 5
    local super_missile_percent = max_super_missiles / 5
    local power_bomb_percent = max_power_bombs / 5
    local energy_percent = math.floor(max_health / 100)
    local reserve_percent = max_reserve_health / 100
    local item_percent = count_set_bits(collected_items)
    local beam_percent = count_set_bits(collected_beams)

    local total_percent = missile_percent +
        super_missile_percent +
        power_bomb_percent +
        energy_percent +
        reserve_percent +
        item_percent +
        beam_percent
    return total_percent .. '%'
end

while true do
    local time = get_time()
    gui.text(text_x, text_y, time)
    gui.text(char_width * (string.len(time) + 2) + text_x, text_y, get_percent())

    emu.frameadvance()
end
