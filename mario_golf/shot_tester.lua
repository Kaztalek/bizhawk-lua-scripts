-- tool to help test shots by varying angle and power
dofile("lib/visual_frame_helpers.lua")

local addr_angle = 0xfbe48
local addr_bar_length = 0xfbe8b -- power ranges from 0 to 29 (seems to differ sometimes?)

local angle = mainmemory.read_u16_be(addr_angle)
local default_bar_length = 29

local script_active = true
local shotRequested = false

function execute_shot()
    local written_angle = tonumber(forms.gettext(textbox_angle))
    local written_bar_length = tonumber(forms.gettext(textbox_bar_length))
    mainmemory.write_u16_be(addr_angle, written_angle)
    local wasPaused = client.ispaused()
    client.unpause()
    to_fresh_visual_frame()
    advance_visual_frame(function ()
        joypad.set({A=1}, 1)
        mainmemory.write_u8(addr_bar_length, written_bar_length)
    end)
    advance_visual_frame()
    advance_visual_frame(function ()
        joypad.set({A=1}, 1)
    end)
    if wasPaused then
        client.pause()
    end
end

function copy_angle()
    forms.settext(textbox_angle, angle)
end

function get_angle_label_text()
    return "Angle: " .. angle
end

event.onexit(function ()
    forms.destroyall()
end)

window = forms.newform(324, 94, "Shot Tester", function () script_active = false end)

textbox_angle = forms.textbox(window, angle, 100, 20, "UNSIGNED", 8, 24)
forms.label(window, "Angle", 8, 8)

textbox_bar_length = forms.textbox(window, default_bar_length, 100, 20, "UNSIGNED", 116, 24)
forms.label(window, "Power", 116, 8)

forms.button(window, "Execute Shot", function () shotRequested = true end, 224, 23)

forms.button(window, "Copy Angle", copy_angle, 8, 64)
angle_label = forms.label(window, get_angle_label_text(), 8, 48)

local last_angle = angle

while script_active do
    if (shotRequested) then
        shotRequested = false
        execute_shot()
    end
    angle = mainmemory.read_u16_be(addr_angle)
    if (angle ~= last_angle) then
        forms.settext(angle_label, get_angle_label_text())
        last_angle = angle
    end
    emu.yield()
end
