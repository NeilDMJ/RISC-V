library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity instr_mem_simple is
    port (
        addr  : in  STD_LOGIC_VECTOR(31 downto 0);
        instr : out STD_LOGIC_VECTOR(31 downto 0)
    );
end instr_mem_simple;

architecture rtl of instr_mem_simple is

    type mem_t is array (0 to 31) of STD_LOGIC_VECTOR(31 downto 0);
    signal rom : mem_t := (
        -- 0x00: addi x10,x0,7      ; n = 7
        0  => x"00700513",

        -- 0x04: addi x13,x0,0      ; a = 0
        1  => x"00000693",

        -- 0x08: addi x14,x0,1      ; b = 1
        2  => x"00100713",

        -- 0x0C: addi x12,x0,0      ; iter = 0
        3  => x"00000613",

        -- 0x10: addi x20,x0,0      ; ptr = 0
        4  => x"00000A13",

        -- 0x14: sw x14,0(x20)      ; mem[0] = 1
        5  => x"00EA2023",

        -- 0x18: addi x20,x20,4     ; ptr = 4
        6  => x"004A0A13",

        -- 0x1C: addi x10,x10,-1    ; n--
        7  => x"FFF50513",

        -- 0x20: add x11,x0,x14     ; result = 1
        8  => x"00E005B3",

        -- 0x24: loop: add x15,x13,x14   ; temp = a + b
        9  => x"00E687B3",

        -- 0x28: add x13,x0,x14     ; a = b
        10 => x"00E006B3",

        -- 0x2C: add x14,x0,x15     ; b = temp
        11 => x"00F00733",

        -- 0x30: addi x12,x12,1     ; iter++
        12 => x"00160613",

        -- 0x34: sw x14,0(x20)      ; mem[ptr] = b
        13 => x"00EA2023",

        -- 0x38: addi x20,x20,4     ; ptr += 4
        14 => x"004A0A13",

        -- 0x3C: add x11,x0,x14     ; result = b
        15 => x"00E005B3",

        -- 0x40: addi x10,x10,-1    ; n--
        16 => x"FFF50513",

        -- 0x44: beq x10,x0,fin     ; salto a 0x4C
        17 => x"00050463",

        -- 0x48: beq x0,x0,loop     ; salto a 0x24
        18 => x"FC000EE3",

        -- 0x4C: fin: beq x0,x0,fin ; bucle infinito
        19 => x"00000063",

        -- resto NOPs
        others => x"00000013"      -- ADDI x0,x0,0
    );

begin
    -- PC es dirección en bytes; rom index = addr / 4
    instr <= rom(to_integer(unsigned(addr(6 downto 2))));
end rtl;