-- hachiemon_ingame.lua
-- Initially written by Kaztalek, small modifications by Trysdyn
-- For use in Hachiemon on Bizhawk

-- Constant(s):
frame_to_centi = 100 / 60  -- 100 centiseconds / 60FPS. 5/3 also works.

-- Addresses:
lvlAddr = 0xac -- Level
minuteAddr = 0xb8 -- Ingame time minutes
secondAddr = 0xb9 -- Ingame time seconds
frameAddr = 0xba -- Ingame time frames

-- Function to format the ingame time display
function readTime()
    level = memory.readbyte(lvlAddr) + 1
    minutes = memory.readbyte(minuteAddr)
    seconds = memory.readbyte(secondAddr)
    frames = memory.readbyte(frameAddr)
    centi = frames * frame_to_centi

    return string.format("Level %d - %02d:%02d.%02d (%d Frames)", level, minutes, seconds, centi, frames)
end

memory.usememorydomain("IWRAM")

-- Main loop
while true do
    gui.text(0, 0, readTime())
    emu.frameadvance()
end