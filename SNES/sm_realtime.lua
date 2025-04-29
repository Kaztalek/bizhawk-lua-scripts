-- "SMrealtime.lua"
-- converts frame count to real time, with optional offset

local offset = 518

local x = 135
local y = 14
local char_width = 9

function pad_2_digits(num)
    if num < 10 then
        return '0' .. num
    end
    return num
end

function get_realtime()
    local framecount = emu.framecount() - offset
    local hours = math.floor(framecount / 216000)
    local minutes = math.floor(framecount / 3600) % 60
    local seconds = math.floor(framecount / 60) % 60
    local frames = framecount % 60
    return hours .. ':' ..
        pad_2_digits(minutes) .. ':' ..
        pad_2_digits(seconds) .. '.' ..
        pad_2_digits(frames)
end

while true do
    local realtime = get_realtime()

    gui.text(x, y, realtime)

    emu.frameadvance()
end
