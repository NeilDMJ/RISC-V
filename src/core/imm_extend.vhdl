library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ImmExtend is
    port (
        imm_in  : in  STD_LOGIC_VECTOR(11 downto 0);  -- inmediato de 12 bits
        imm_ext : out STD_LOGIC_VECTOR(31 downto 0)   -- inmediato extendido a 32 bits
    );
end ImmExtend;

architecture Behavioral of ImmExtend is
begin
    process(imm_in)
    begin
        -- Extensión de signo del inmediato de 12 bits a 32 bits
        if imm_in(11) = '1' then
            imm_ext <= (31 downto 12 => '1') & imm_in;  -- numero negativo
        else
            imm_ext <= (31 downto 12 => '0') & imm_in;  -- numero positivo
        end if;
    end process;
end Behavioral;