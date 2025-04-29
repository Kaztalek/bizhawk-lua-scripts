-- "popn_times.lua"

json = require "libraries/json"

dofile("lib/popn_screens.lua")

local times = {}
local filename = "data/popn/times.json"
local file = io.open(filename, "r")
if file then
    times = json.decode(file:read("*all"))
    file:close()
end

local addr_frame_count = 0x54

local last_screen = get_screen()
local last_frame_count = 0

event.onloadstate(function ()
    last_screen = get_screen()
end)

event.onexit(function()
    file = io.open(filename, "w")
    file:write(json.encode(times))
    file:close()
end)

function frames_to_time(frames)
    if not frames then
        return "-"
    end
    local minutes = math.floor(frames / 60 / 60)
    local seconds = math.floor(frames / 60) % 60
    local remainder = frames % 60
    return minutes .. "'" .. bizstring.pad_start(seconds, 2, "0") .. "\"" .. bizstring.pad_start(remainder, 2, "0")
end

local text_height = 14
local text_x = 0
local text_y = text_height * 6
function print_text(screen, frame_count, best)
    gui.text(text_x, text_y, "Screen " .. screen)
    gui.text(text_x, text_y + text_height, "Best: " .. frames_to_time(best))
    gui.text(text_x, text_y + text_height * 2, "Now: " .. frames_to_time(frame_count))
end

while true do
    -- TODO save last frame_count for furniture wizard
    local frame_count = memory.read_u16_le(addr_frame_count)
    local screen = get_screen()
    local best = times[last_screen]
    if screen ~= last_screen then
        local line_no = screens[last_screen]
        if line_no and screens[screen] == line_no + 1 then
            -- restore last frame count if set to 0 on next room
            if frame_count == 0 then
                frame_count = last_frame_count
            end
            if not best or frame_count < best  then
                times[last_screen] = frame_count
            end
            client.pause()
        end
        last_screen = screen
    end
    last_frame_count = frame_count
    print_text(screen, frame_count, best)
    emu.frameadvance()
end
