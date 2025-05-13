-- displays game time and item percentage for Super Junkoid 1.3
-- 100% entails 70 items:
-- - 12 equipment upgrades
-- - 4 gems
-- - 20 hearts (600 max health)
-- - 15 magic bolt pickups (75 capacity)
-- - 10 baseball pickups (50 capacity)
-- - 5 spark swimsuit pickups (25 capacity)
-- - 4 lucky frogs (200 max lucky frog health)

local addrs = {
    -- bitfield; low bit to high bit:
    -- 0: Purple Locket
    -- 1: Wave Bangle
    -- 2: Rat Cloak
    -- 3: Wallkicks
    -- 5: Sanguine Fin
    -- 8: Feather
    -- 9: Magic Broom
    -- B: Big League Gloves
    -- C: Rat Burst
    -- D: Rat Dasher
    -- E: Dreamer's Crown
    -- F: Magic Soap
    item_flags = 0x9a4,
    -- bitfield; low bit to high bit:
    -- 0: Gem of Blood
    -- 1: Gem of Ice
    -- 3: Gem of Storms
    -- C: Gem of Death
    gem_flags = 0x9a8,
    max_health = 0x9c4,
    magic_bolt_capacity = 0x9c8,
    baseball_capacity = 0x9cc,
    spark_swimsuit_capacity = 0x9d0,
    max_lucky_frog_health = 0x9d4,
    -- game time
    frames = 0x9da,
    seconds = 0x9dc,
    minutes = 0x9de,
    hours = 0x9e0
}

-- constants
local STARTING_HEALTH = 100
local HEART_VALUE = 25
local MAGIC_BOLT_VALUE = 5
local BASEBALL_VALUE = 5
local SPARK_SWIMSUIT_VALUE = 5
local LUCKY_FROG_VALUE = 50
local TOTAL_CHECKS = 70

function pad_2_digits(num)
    if num < 10 then
        return '0' .. num
    end
    return num
end

function count_set_bits(n)
    local count = 0
    while n > 0 do
        count = count + (n & 1)
        n = n >> 1
    end
    return count
end

function get_time()
    local hours = memory.readbyte(addrs["hours"])
    local minutes = memory.readbyte(addrs["minutes"])
    local seconds = memory.readbyte(addrs["seconds"])
    local frames = memory.readbyte(addrs["frames"])
    return hours .. ':' ..
        pad_2_digits(minutes) .. ':' ..
        pad_2_digits(seconds) .. '.' ..
        pad_2_digits(frames)
end

function get_check_count()
    local collected_items = memory.read_u16_le(addrs["item_flags"])
    local collected_gems = memory.read_u16_le(addrs["gem_flags"])
    local max_health = memory.read_u16_le(addrs["max_health"])
    local magic_bolt_capacity = memory.readbyte(addrs["magic_bolt_capacity"])
    local baseball_capacity = memory.readbyte(addrs["baseball_capacity"])
    local spark_swimsuit_capacity = memory.readbyte(addrs["spark_swimsuit_capacity"])
    local max_lucky_frog_health = memory.read_u16_le(addrs["max_lucky_frog_health"])

    local item_count = count_set_bits(collected_items)
    local gem_count = count_set_bits(collected_gems)
    local heart_pickups = (max_health - STARTING_HEALTH) / HEART_VALUE
    local magic_bolt_pickups = magic_bolt_capacity / MAGIC_BOLT_VALUE
    local baseball_pickups = baseball_capacity / BASEBALL_VALUE
    local spark_swimsuit_pickups = spark_swimsuit_capacity / SPARK_SWIMSUIT_VALUE
    local lucky_frog_pickups = max_lucky_frog_health / LUCKY_FROG_VALUE

    local check_count = item_count + gem_count + heart_pickups + magic_bolt_pickups + baseball_pickups + spark_swimsuit_pickups + lucky_frog_pickups
    return math.floor(check_count)
end

function get_percent_str(check_count)
    local percent = check_count / TOTAL_CHECKS * 100
    return string.format("%.1f", percent) .. "%"
end

local text_x = 0
local text_y = 14
local text_height = 14

while true do
    local time = get_time()
    gui.text(text_x, text_y, time)
    local check_count = get_check_count()
    local percent_str = get_percent_str(check_count)
    gui.text(text_x, text_y + text_height, check_count .. "/" .. TOTAL_CHECKS .. " (" .. percent_str .. ")")
    emu.frameadvance()
end
