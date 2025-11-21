library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- MUX 2 a 1 de 12 bits para seleccionar el formato del inmediato (tipo I o tipo S)
entity mux2to1_12bit is
    port (
        input0  : in  STD_LOGIC_VECTOR(11 downto 0); -- opción 0 (p.ej. tipo I)
        input1  : in  STD_LOGIC_VECTOR(11 downto 0); -- opción 1 (p.ej. tipo S)
        sel     : in  STD_LOGIC;                     -- 0 -> input0, 1 -> input1
        output  : out STD_LOGIC_VECTOR(11 downto 0)
    );
end mux2to1_12bit;

architecture Behavioral of mux2to1_12bit is
begin
    process(input0, input1, sel)
    begin
        if sel = '0' then
            output <= input0;
        else
            output <= input1;
        end if;
    end process;
end Behavioral;