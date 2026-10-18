memory.usememorydomain("RDRAM")

addr_visual_frame = 0xb67f0
addr_inter_frame = 0xb678f -- 0 inbetween vframes, 1 on new vframe

function get_visual_frame()
    return memory.read_u32_be(addr_visual_frame)
end

-- since Mario Golf skips inputs inbetween vframes, it helps to get to the next vframe before doing inputs
function to_fresh_visual_frame()
    while memory.read_u8(addr_inter_frame) == 0 do
        emu.frameadvance()
    end
end

function advance_visual_frame(callback)
    local visual_frame = get_visual_frame()
    while memory.read_u32_be(addr_visual_frame) == visual_frame do
        if callback then
            callback()
        end
        emu.frameadvance()
    end
end
