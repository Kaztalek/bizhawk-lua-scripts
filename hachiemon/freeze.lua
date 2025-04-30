--"freeze.lua"
--For use in Hachiemon on Bizhawk 1.9.1

while true do
	memory.writebyte(0x00AC,4)
	emu.frameadvance()
end