library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Sumador que calcula PC + 4
entity pc_adder4 is
    port (
        pc_in    : in  STD_LOGIC_VECTOR(31 downto 0); -- PC actual
        pc_plus4 : out STD_LOGIC_VECTOR(31 downto 0)  -- PC + 4
    );
end pc_adder4;

architecture Behavioral of pc_adder4 is
begin
    pc_plus4 <= std_logic_vector(unsigned(pc_in) + 4);
end Behavioral;