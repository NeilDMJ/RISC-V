library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity mux2to1 is
    port (
        input0  : in STD_LOGIC_VECTOR(31 downto 0);  --entrada 0
        input1  : in STD_LOGIC_VECTOR(31 downto 0);  --entrada 1
        sel     : in STD_LOGIC;                      --selector (0=input0, 1=input1)
        output  : out STD_LOGIC_VECTOR(31 downto 0)  --salida
    );
end mux2to1;

architecture behavioral of mux2to1 is
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
