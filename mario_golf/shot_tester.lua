-- tool to help test shots by varying angle and power
dofile("lib/visual_frame_helpers.lua")

local addr_strength = 0xfbe57 -- long 0, medium 1, short 2
local addr_bar_length = 0xfbe8b -- power ranges from 0 to 29 (seems to differ sometimes?)
local addr_angle = 0xfbe48

local angle = mainmemory.read_u16_be(addr_angle)
local default_bar_length = 29
local history = {}
local history_limit = 10

local script_active = true
local shotRequested = false

-- returns whether or not it updated, so shot can be delayed if necessary
function set_strength(strength)
    local last_val = mainmemory.read_u8(addr_strength)
    local strength_val = 0
    if strength == "Medium" then
        strength_val = 1
    elseif strength == "Short" then
        strength_val = 2
    end
    mainmemory.write_u8(addr_strength, strength_val)
    return strength_val ~= last_val
end

function import_angle()
    forms.settext(textbox_angle, angle)
end

function set_angle()
    local curr_angle = tonumber(forms.gettext(textbox_angle))
    mainmemory.write_u16_be(addr_angle, curr_angle)
    return curr_angle
end

function get_angle_label_text()
    return "Game angle: " .. angle
end

function execute_shot()
    local curr_strength = forms.gettext(dropdown_strength)
    local delayShot = set_strength(curr_strength)
    local curr_angle = set_angle()
    local curr_bar_length = tonumber(forms.gettext(textbox_bar_length))
    update_history(curr_strength, curr_angle, curr_bar_length)
    local wasPaused = client.ispaused()
    client.unpause()
    to_fresh_visual_frame()
    if delayShot then
        advance_frames(4)
    end
    advance_visual_frame(function ()
        joypad.set({A=1}, 1)
        mainmemory.write_u8(addr_bar_length, curr_bar_length)
    end)
    advance_visual_frame()
    advance_visual_frame(function ()
        joypad.set({A=1}, 1)
    end)
    if wasPaused then
        client.pause()
    end
end

event.onexit(function ()
    forms.destroyall()
end)

local btn_height = 24
local margin_x = 8
local margin_y = 8
local label_height = 16
local text_btn_w = 16
local window_w = 300

local row_power_y = margin_y
local row_power_h = label_height + btn_height
local strength_w = 60
local bar_len_w = 36
local execute_w = 80

local row_angle_y = row_power_y + row_power_h + margin_y
local row_angle_h = label_height + btn_height
local angle_w = 60
local set_angle_w = 80

local row_game_angle_y = row_angle_y + row_angle_h
local row_game_angle_h = label_height + btn_height
local import_angle_w = 92

local row_history_y = row_game_angle_y + row_game_angle_h + margin_y
local row_history_h = label_height + btn_height * history_limit

window = forms.newform(window_w, row_history_y + row_history_h + margin_y, "Shot Tester", function () script_active = false end)

------ Power Row
function update_bar_len(amount)
    forms.settext(textbox_bar_length, tonumber(forms.gettext(textbox_bar_length)) + amount)
end

dropdown_strength = forms.dropdown(window, {"Long", "Medium", "Short"}, margin_x, row_power_y + label_height, strength_w, btn_height)

forms.button(window, "-", function () update_bar_len(-1) end, margin_x + strength_w + margin_x, row_power_y + label_height, text_btn_w, btn_height)
textbox_bar_length = forms.textbox(window, default_bar_length, bar_len_w, btn_height, "UNSIGNED", margin_x + strength_w + margin_x + text_btn_w, row_power_y + label_height)
forms.button(window, "+", function () update_bar_len(1) end, margin_x + strength_w + margin_x + bar_len_w + text_btn_w, row_power_y + label_height, text_btn_w, btn_height)

forms.label(window, "Power", margin_x, row_power_y)

forms.button(window, "Execute shot", function () shotRequested = true end, window_w - execute_w - margin_x, row_power_y + label_height, execute_w, btn_height)
------

------ Angle Row
function update_angle(amount)
    forms.settext(textbox_angle, tonumber(forms.gettext(textbox_angle)) + amount)
end

forms.button(window, "-", function () update_angle(-1) end, margin_x, row_angle_y + label_height, text_btn_w, btn_height)
textbox_angle = forms.textbox(window, angle, angle_w, btn_height, "UNSIGNED", margin_x + text_btn_w, row_angle_y + label_height)
forms.button(window, "+", function () update_angle(1) end, margin_x + angle_w + text_btn_w, row_angle_y + label_height, text_btn_w, btn_height)

forms.button(window, "Set angle →", set_angle, margin_x + angle_w + text_btn_w + text_btn_w + margin_x, row_angle_y + label_height, set_angle_w, btn_height)

forms.label(window, "Angle", margin_x, row_angle_y)
------

------ Game Angle Row
forms.button(window, "Import angle ↑", import_angle, margin_x, row_game_angle_y + label_height, import_angle_w, btn_height)

angle_label = forms.label(window, get_angle_label_text(), margin_x, row_game_angle_y)
------

------ History
function update_history(curr_strength, curr_angle, curr_bar_length)
    table.insert(history, forms.label(window, "Angle: " .. curr_angle .. ", Power: " .. curr_bar_length .. " (" .. curr_strength .. ")", nil, nil, window_w - 2 * margin_x, label_height))
    for i = 1, #history do
        if i > #history - history_limit then
            forms.setlocation(history[i], margin_x, row_history_y + label_height + btn_height * (#history - i))
        else
            -- forms api is weird, doesn't seem to be a way to clear just the label or even write over it for some reason
            forms.setlocation(history[i], -100, -100)
        end
    end
end

history_label = forms.label(window, "History", margin_x, row_history_y, window_w - 2 * margin_x, label_height)
------

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
