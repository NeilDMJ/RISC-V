library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- MUX del PC:
-- sel = '0' -> PC + 4
-- sel = '1' -> PC + offset de branch
entity pc_mux is
    port (
        pc_plus4 : in  STD_LOGIC_VECTOR(31 downto 0); -- camino secuencial
        pc_br    : in  STD_LOGIC_VECTOR(31 downto 0); -- camino de branch
        sel      : in  STD_LOGIC;                     -- branch_taken
        pc_next  : out STD_LOGIC_VECTOR(31 downto 0)  -- siguiente PC
    );
end pc_mux;

architecture Behavioral of pc_mux is
begin
    process(pc_plus4, pc_br, sel)
    begin
        if sel = '0' then
            pc_next <= pc_plus4;
        else
            pc_next <= pc_br;
        end if;
    end process;
end Behavioral;