-- Author: KirkQ
local CharID = 0x7E1000
local OnGround = 0x7E1002  -- 8 on ground, not 8 in air
local XPos = 0x7E1004
local XSubpixel = 0x7E1006
local XVelocity = 0x7E100C
local YPos = 0x7E1008
local YSubpixel = 0x7E100A
local YVelocity = 0x7E100E
local JumpAd = 0x7E0056

local Health = 0x7E051A



local XVel
local YVel
local LastXPos = 0
local CurrXPos = 0
local LastXSub = 0
local CurrXSub = 0
local LastYPos = 0
local CurrYPos = 0
local LastYSub = 0
local CurrYSub = 0

local BossY = 0x7E0C02  --7E0C02, 7E0C12, 7E1098
local BossAction = 0x7E10A0
local BossHealth = 0x7E051C

local RealXVel = {}
--Note that a knockback speed of 15 just holds the previous speed for a frame
RealXVel[0]= 0
RealXVel[14] = 3.4375
RealXVel[13] = 3.3633
RealXVel[12] = 3.2930
RealXVel[11] = 3.1094
RealXVel[10]= 3.035
RealXVel[9]= 2.9258
RealXVel[8]= 2.8164
RealXVel[7]= 2.75
RealXVel[6]= 2.3047
RealXVel[5]= 2.0117
RealXVel[4]= 1.535
RealXVel[3]= 1.0625
RealXVel[2]= 1
RealXVel[1]= 1
RealXVel[-14] = -3.4375
RealXVel[-13] = -3.3633
RealXVel[-12] = -3.2930
RealXVel[-11] = -3.109
RealXVel[-10]= -3.035
RealXVel[-9]= -2.9258
RealXVel[-8]= -2.8164
RealXVel[-7]= -2.75
RealXVel[-6]= -2.3047
RealXVel[-5]= -2.0117
RealXVel[-4]= -1.535
RealXVel[-3]= -1.0625
RealXVel[-2]= -2
RealXVel[-1]= -2

local RealYVel = {}

RealYVel[-28] = -8.3633
RealYVel[-27] = -8.3633
RealYVel[-26] = -8.2773
RealYVel[-25] = -8.1054
RealYVel[-24] = -8.0195
RealYVel[-23] = -7.8516
RealYVel[-22] = -7.6797
RealYVel[-21] = -7.5078
RealYVel[-20] = -7.2539
RealYVel[-19] = -7.0820
RealYVel[-18] = -6.8281
RealYVel[-17] = -6.5703
RealYVel[-16] = -6.3164
RealYVel[-15] = -5.9726
RealYVel[-14] = -5.7187
RealYVel[-13] = -5.3750
RealYVel[-12] = -5.0351
RealYVel[-11] = -4.6914
RealYVel[-10] = -4.3516
RealYVel[-9] = -4.0117
RealYVel[-8] = -3.5859
RealYVel[-7] = -3.2422
RealYVel[-6] = -2.8164
RealYVel[-5] = -2.4766
RealYVel[-4] = -2.0469
RealYVel[-3] = -1.6211
RealYVel[-2] = -1.1953
RealYVel[-1] = -0.7695
RealYVel[0] = -0.3398
RealYVel[1] = 2.0469
RealYVel[2] = 2.4766
RealYVel[3] = 2.0469
RealYVel[4] = 2.4766
RealYVel[5] = 2.8164
RealYVel[6] = 3.2422
RealYVel[7] = 3.5859
RealYVel[8] = 4.0117
RealYVel[9] = 4.3516
RealYVel[10] = 4.6914
RealYVel[11] = 5.0352
RealYVel[12] = 5.3750
RealYVel[13] = 5.7187
RealYVel[14] = 5.9727
RealYVel[15] = 6.3164
RealYVel[16] = 6.5703
RealYVel[17] = 6.8281
RealYVel[18] = 7.0820
RealYVel[19] = 7.2539
RealYVel[20] = 7.5078
RealYVel[21] = 7.6797
RealYVel[22] = 7.8516
RealYVel[23] = 8.0195
RealYVel[24] = 8.1055
RealYVel[25] = 8.2773
RealYVel[26] = 8.3633
RealYVel[27] = 8.3633
RealYVel[28] = 8.4492
RealYVel[29] = 8.4492
RealYVel[30] = 8.5351
RealYVel[31] = 9.4414
RealYVel[32] = 10.078
RealYVel[33] = 10.719
RealYVel[34] = 11.199
RealYVel[35] = 11.840
RealYVel[36] = 12.320
RealYVel[37] = 12.801
RealYVel[38] = 13.281
RealYVel[39] = 13.602
RealYVel[40] = 14.078
RealYVel[41] = 14.398
RealYVel[42] = 14.719
--anything over 42 is 14.719

local Offset
local Flag
local Count

local CurrBossY
local MaxBossY = 100

while true do

--memory.writebyte(Health,6)
--CurrBossY = memory.read_u16_le(BossY)
--CurrAction = memory.readbyte(BossAction)
--if CurrBossY > MaxBossY and CurrAction ~= 11 and CurrAction ~= 12 and CurrAction ~= 13 and CurrBossY < 1000 then
--MaxBossY = CurrBossY
--end

--gui.text(200,100,"Curr: " .. memory.read_u16_le(BossY))
--gui.text(200,115,"Max: " .. MaxBossY) --523
--gui.text(200,130,"BHealth: " .. memory.read_u16_le(BossHealth))


Offset = 0x0
Flag = 0
Count = 0
while Flag~=1 do
	if memory.read_u16_le(CharID + Offset) ~= 40713 then
	Offset = Offset + 0x30
	Count = Count + 1
	else
	Flag = 1
	end
	if Count > 30 then
	Flag = 1
	gui.text(60,85,"SEARCHING")
	end
end


XVel = memory.readbyte(XVelocity + Offset)
if XVel > 200 then
XVel = XVel - 256
end
YVel = memory.readbyte(YVelocity + Offset)
if YVel > 200 then
YVel = YVel - 256
end

LastXPos = CurrXPos
CurrXPos = memory.read_u16_le(XPos + Offset)
LastXSub = CurrXSub
CurrXSub = memory.read_u16_le(XSubpixel + Offset)/65535
LastYPos = CurrYPos
CurrYPos = memory.read_u16_le(YPos + Offset)
LastYSub = CurrYSub
CurrYSub = memory.read_u16_le(YSubpixel + Offset)/65535

gui.text(35,0,"XVel: " .. XVel)
gui.text(35,40,"YVel: " .. YVel)

InterpX = CurrXPos + CurrXSub - LastXPos - LastXSub
InterpY = CurrYPos + CurrYSub - LastYPos - LastYSub

if InterpX > -0.001 and InterpX < 0.001 then
InterpX = 0
end
if InterpY> -0.001 and InterpY < 0.001 then
InterpY = 0
end

	if XVel <= 14 and XVel >= -14 then 
	gui.text(240,0,"RealVel: " .. RealXVel[XVel])
	else
	gui.text(240,0,"InterpVel: " .. InterpX)
	end
	
	if YVel >= -28 then
		if YVel > 42 then
		YVel = 42
		end
		if YVel ~= 0 or (YVel == 0 and memory.readbyte(OnGround + Offset) ~=8) then
		gui.text(240,40,"RealVel: " .. RealYVel[YVel])
		else
		gui.text(240,40,"RealVel: 0")
		end
	else
	gui.text(240,40,"InterpVel: " .. InterpY)
	end

if XVel <= 14 and XVel >= -14 then
	if math.abs(InterpX - RealXVel[XVel]) > 0.05 then
	gui.text(550,0,"?")
	end
end
if YVel >= -17 and YVel ~= 0 then
	if math.abs(InterpY - RealYVel[YVel]) > 0.05 then
	gui.text(550,40,"?")
	end
end
if YVel == 0 then
	--On ground
	if memory.readbyte(OnGround + Offset) == 8 then
		if math.abs(InterpY - 0) > 0.05 then
		gui.text(550,40,"?")
		end
	-- In air
	elseif math.abs(InterpY - RealYVel[YVel]) > 0.05 then
	gui.text(550,40,"?")
	end
end

gui.text(240,15,"InterpVel: " .. InterpX)
gui.text(240,55,"InterpVel: " .. InterpY)



gui.text(35,15,"Xpos: " .. CurrXPos)
gui.text(35,55,"Ypos: " .. CurrYPos)

if CurrXSub*100 < 10 and CurrXSub*100 > 0 then
gui.text(135,15," . 0")
gui.text(175,15,math.floor(CurrXSub*100))
else
gui.text(135,15," . " .. math.floor(CurrXSub*100))
end

if CurrYSub*100 < 10 and CurrYSub*100 > 0 then
gui.text(135,55," . 0")
gui.text(175,55,math.floor(CurrYSub*100))
else
gui.text(135,55," . " .. math.floor(CurrYSub*100))
end

gui.text(240,70,"Jump: " .. memory.readbyte(JumpAd))

emu.frameadvance();
end
