library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity mux2to1_5bit is
    port (
        input0  : in STD_LOGIC_VECTOR(4 downto 0);  --entrada 0 (5 bits)
        input1  : in STD_LOGIC_VECTOR(4 downto 0);  --entrada 1 (5 bits)
        sel     : in STD_LOGIC;                     --selector (0=input0, 1=input1)
        output  : out STD_LOGIC_VECTOR(4 downto 0)  --salida (5 bits)
    );
end mux2to1_5bit;

architecture behavioral of mux2to1_5bit is
begin
    process(input0, input1, sel)
    begin
        if sel = '0' then
            output <= input0;
        else
            output <= input1;
        end if;
    end process;
end behavioral;
