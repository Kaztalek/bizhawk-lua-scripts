memory.usememorydomain("WRAM")

local addr_room = 0x480
local addr_entrance = 0x482
local addr_map_jump = 0x486

local default_room = memory.read_u8(addr_room)
local default_entrance = memory.read_u8(addr_entrance)

function execute_map_jump()
    local room = tonumber(forms.gettext(textbox_room))
    local entrance = tonumber(forms.gettext(textbox_entrance))
    memory.write_u8(addr_room, room)
    memory.write_u8(addr_entrance, entrance)
    memory.write_u8(addr_map_jump, 1)
end


window = forms.newform(324, 94, "Map Jump")

textbox_room = forms.textbox(window, default_room, 100, 20, "UNSIGNED", 8, 24)
forms.label(window, "Room", 8, 8)

textbox_entrance = forms.textbox(window, default_entrance, 100, 20, "UNSIGNED", 116, 24)
forms.label(window, "Entrance", 116, 8)

forms.button(window, "Map Jump", execute_map_jump, 224, 23)
