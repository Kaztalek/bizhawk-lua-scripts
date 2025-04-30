-- displays game time and item percentage for Junkoid 1.1
memory.usememorydomain("WRAM")

local addrs = {
    -- increments by 1 every 256 frames
    -- 3 bytes, but just read 2 for convenience as the high byte should never be reached
    game_time = 0x87d,
    -- 1 byte
    heart_case_count = 0x877,
    -- 1 byte
    baseball_capacity = 0x87a,
    -- 1 byte, bitfield
    -- low bit to high bit:
    -- 0: Rat Bombs
    -- 1: Feather
    -- 2: Silver Ring
    -- 3: Death's Scythe
    -- 4: Rat Cloak
    -- 5: Pink Dress
    -- 6: Ring of Fire
    -- 7: Penguin's Ring
    equipment_flags = 0x878
}

local text_x = 0
local text_y = 14
local text_height = 14

function count_set_bits(n)
    local count = 0
    while n > 0 do
        count = count + (n & 1)
        n = n >> 1
    end
    return count
end

function pad_2_digits(num)
    if num < 10 then
        return '0' .. num
    end
    return num
end

-- return how much game time has passed
-- currently returns as-is
-- could probably translate to h:mm:ss by counting additional frames after each game time tick
-- if so, remember to account for paused game time!
function get_time()
    return memory.read_s16_le(addrs["game_time"])
end
function get_time_estimate_str(game_time)
    local game_time_frames = game_time * 256
    local hours = math.floor(game_time_frames / 216000)
    local minutes = math.floor(game_time_frames / 3600) % 60
    local seconds = math.floor(game_time_frames / 60) % 60
    return hours .. ':' ..
        pad_2_digits(minutes) .. ':' ..
        pad_2_digits(seconds)
end

-- 100% entails:
-- - 150 Baseball capacity
-- - 5 Heart Cases
-- - 8 equipment upgrades
-- for now, treat each as an equal chunk of item completion:
-- - 5 Baseball capacity
-- - 1 Heart Case
-- - 1 equipment upgrade
local ITEM_DIVISOR = 43
function get_percent()
    local heart_case_count = memory.read_u8(addrs["heart_case_count"])
    local baseball_capacity = memory.read_u8(addrs["baseball_capacity"])
    local equipment_flags = memory.read_u8(addrs["equipment_flags"])

    local item_count = baseball_capacity / 5 + heart_case_count + count_set_bits(equipment_flags)
    return item_count / ITEM_DIVISOR * 100
end

while true do
    local game_time = get_time()
    gui.text(text_x, text_y, "game time: " .. game_time .. " (~" .. get_time_estimate_str(game_time) .. ")")
    gui.text(text_x, text_y + text_height, string.format("%.2f", get_percent()) .. "%")
    gui.text(text_x, text_y + text_height * 2, "BASEBALL capacity: " .. memory.read_u8(addrs["baseball_capacity"]))
    emu.frameadvance()
end
