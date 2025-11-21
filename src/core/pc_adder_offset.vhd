library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Sumador que calcula PC + offset de branch
entity pc_adder_offset is
    port (
        pc_in   : in  STD_LOGIC_VECTOR(31 downto 0); -- PC actual
        offset  : in  STD_LOGIC_VECTOR(31 downto 0); -- offset de branch (branch_offset)
        pc_br   : out STD_LOGIC_VECTOR(31 downto 0)  -- PC + offset
    );
end pc_adder_offset;

architecture Behavioral of pc_adder_offset is
begin
    pc_br <= std_logic_vector(unsigned(pc_in) + unsigned(offset));
end Behavioral;