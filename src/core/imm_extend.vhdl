library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ImmExtend is
    port (
        instr       : in STD_LOGIC_VECTOR(31 downto 0);  -- instruccion completa
        imm_ext     : out STD_LOGIC_VECTOR(31 downto 0)  -- inmediato extendido a 32 bits
    );
end ImmExtend;

architecture Behavioral of ImmExtend is
    signal imm_12bit : STD_LOGIC_VECTOR(11 downto 0);
begin
    -- Tipo I: inmediato de 12 bits en bits [31:20]
    imm_12bit <= instr(31 downto 20);
    
    -- Extension de signo: replicar el bit de signo (bit 31) en los 20 bits superiores
    process(imm_12bit)
    begin
        if imm_12bit(11) = '1' then
            imm_ext <= X"FFFFF" & imm_12bit;  -- Numero negativo
        else
            imm_ext <= X"00000" & imm_12bit;  -- Numero positivo
        end if;
    end process;
end Behavioral;
