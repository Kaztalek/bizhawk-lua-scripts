local state_path = "../../SNES/State/"
local stage = 4
local key = "C"

dofile("lib/screens.lua")

local last_screen = get_screen()

event.onloadstate(function ()
    last_screen = get_screen()
end)

local text_height = 14
local text_x = 0
local text_y = text_height * 6
function print_text(screen)
    gui.text(text_x, text_y, "Screen " .. screen)
end

local key_held = false

while true do
    local screen = get_screen()
    if input.get()[key] then
        if not key_held then
            key_held = true
            local line_no = screens[screen]
            if line_no then
                local path = state_path .. stage .. "/" .. bizstring.pad_start(line_no, 3, "0") .. "_" .. screen .. ".State"
                savestate.save(path)
                console.log("Saved " .. path)
            else
                console.log("add the screen first")
            end
        end
    else
        key_held = false
    end
    if screen ~= last_screen then
        client.pause()
        last_screen = screen
    end
    print_text(screen, time)
    emu.yield()
end
