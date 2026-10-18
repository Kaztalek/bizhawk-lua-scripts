-- inputs the unlock code for TAS
-- from power on to main menu

-----
-- copied and modified from majoras_mask/gz-menu.lua
-- move to library if useful again
dofile("lib/visual_frame_helpers.lua")
local hold_duration = 2 -- how long to hold button while inputting

local last_instruction = {}

function contains_same_input(table1, table2)
    for _, v1 in ipairs(table1) do
        for _, v2 in ipairs(table2) do
            if v1 == v2 then
                return true
            end
        end
    end
    return false
end

function input(instruction)
    if contains_same_input(last_instruction, instruction) then
        advance_visual_frame()
    end
    local pressed = {}
    last_instruction = {}
    for k, v in pairs(instruction) do
        pressed[v] = true
        table.insert(last_instruction, v)
    end
    for i = 1, hold_duration do
        joypad.set(pressed, 1)
        emu.frameadvance()
    end
end

function input_set(inputs)
    for i = 1, #inputs do
        input(inputs[i])
    end
end

function delay(start_frame)
    while true do
        if emu.framecount() >= start_frame then
            return
        end
        emu.frameadvance()
    end
end
-----

delay(368)
input({"Start"})
delay(381)
input_set({
    {"DPad D"},
    {"DPad D"},
    {"DPad L"},
    {"DPad L"},
    {"DPad L"},
    {"DPad R"},
    {"DPad R"},
    {"DPad R"},
    {"C Down"},
    {"C Down"},
    {"C Left"},
    {"C Left"},
    {"C Left"},
    {"C Right"},
    {"C Right"},
    {"C Right"}
})
delay(434)
input({"Start"})
