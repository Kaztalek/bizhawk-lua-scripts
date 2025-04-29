local wch_path = "../Tools/Magical Pop'n (Japan).wch"

-- extends Bizhawk watch functionality to follow pointers
-- takes in an existing .wch file:
-- - prefix the pointers with "*"
-- - prefix values that rely on the pointers with "&" and have them directly underneath the pointer. the address should be the offset
-- displaying values in binary isn't implemented yet because I don't need it. for future: remember to take big/little endian into account
-- TODO memory.readfloat needs to pass endianness as the 2nd argument

-- example .wch:
-- SystemID SNES
-- 0004C6  w   h   0   WRAM    *Princess
-- 000004  w   u   0   WRAM    &X Pos
-- 00051A  b   u   0   WRAM    Health

-- col  | possible values   | description
-- --------------------------------------
-- 1    | 000000 - FFFFFF   | address
-- 2    | b, w, d           | size in bytes. b=1, w=2, d=4
-- 3    | u, s, h, b, f     | display type. u=unsigned, s=signed, h=hex, b=binary, f=float
-- 4    | 0, 1              | endianness. 0=LE, 1=BE
-- 5    | WRAM, VRAM, etc   | domain type. see ram watch in bizhawk for list
-- 6    | any string        | label

-- from http://lua-users.org/wiki/FileInputOutput
function readall(filename)
    local fh = assert(io.open(filename, "rb"))
    local contents = assert(fh:read(_VERSION <= "Lua 5.2" and "*a" or "a"))
    fh:close()
    return contents
end

function to_hex_str(num, include_prefix)
    return (include_prefix and "0x" or "") .. string.format("%X", num)
end

local read_fn_list = {
    s8=memory.read_s8,
    u8=memory.read_u8,
    s16be=memory.read_s16_be,
    u16be=memory.read_u16_be,
    s16le=memory.read_s16_le,
    u16le=memory.read_u16_le,
    s24be=memory.read_s24_be,
    u24be=memory.read_u24_be,
    s24le=memory.read_s24_le,
    u24le=memory.read_u24_le,
    s32be=memory.read_s32_be,
    u32be=memory.read_u32_be,
    s32le=memory.read_s32_le,
    u32le=memory.read_u32_le,
    f=memory.readfloat
}
-- return the appropriate memory read function based on data from .wch
function get_read_fn(size, display, endian)
    if display == "f" then
        return memory.readfloat
    end
    local sign = "u"
    if display == "s" then
        sign = "s"
    end
    local size_to_total_bits = {
        b=8,
        w=16,
        d=32
    }
    local total_bits = size_to_total_bits[size]
    local endian_str = ""
    if total_bits ~= 8 then
        endian_str = endian == "1" and "be" or "le"
    end
    return read_fn_list[sign .. total_bits .. endian_str]
end

-- convert .wch file to table
-- do one-time processes here, so data is easier to parse during runtime
local wch_table = {}
local wch_data = readall(wch_path)
for line in wch_data:gmatch("([^\n]+)\n") do
    for addr, size, display, endian, domain, label in line:gmatch("([^\t]+)\t([^\t]+)\t([^\t]+)\t([^\t]+)\t([^\t]+)\t([^\r\n]+)") do
        local symbol = label:sub(1, 1)
        local is_ptr = symbol == "*"
        local is_offset = symbol == "&"
        local name = (is_ptr or is_offset) and label:sub(2, #label) or label
        table.insert(wch_table, {
            addr=tonumber(addr, 16),
            read_fn=get_read_fn(size, display, endian),
            is_ptr=is_ptr,
            is_offset=is_offset,
            is_hex=display == "h",
            domain=domain,
            name=name
        })
        -- print(label)
    end
end

local text_height = 14
local text_x = 0
local text_y = text_height * 2
function screen_print(label, value, line_no)
    -- print(label .. ": " .. value)
    gui.text(text_x, text_y + text_height * line_no, label .. ": " .. value)
end

while true do
    local base_addr = 0
    for index, entry in pairs(wch_table) do
        local label = entry.name
        local addr = entry.addr
        if entry.is_offset then
            addr = base_addr + addr
            -- print offsets with indentation
            label = "  " .. entry.name
        end
        local value = entry.read_fn(addr, entry.domain)
        if entry.is_ptr then
            base_addr = value
            -- don't print pointer values
            value = ""
        elseif entry.is_hex then
            value = to_hex_str(value)
        end
        screen_print(label, value, index)
    end
    emu.frameadvance()
end
