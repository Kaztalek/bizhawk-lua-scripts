-- press specified key to get to next visual frame
key = "RightBracket"

dofile("lib/visual_frame_helpers.lua")

local toggle_frame_advance = false

while true do
    if input.get()[key] then
        if not toggle_frame_advance then
            toggle_frame_advance = true
            client.unpause()
            advance_visual_frame()
            client.pause()
        end
    else
        toggle_frame_advance = false
    end
    emu.yield()
end
