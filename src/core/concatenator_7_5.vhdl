library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity concatenator_7_5 is
    port (
        input_7bits : in STD_LOGIC_VECTOR(6 downto 0);   --entrada de 7 bits
        input_5bits : in STD_LOGIC_VECTOR(4 downto 0);   --entrada de 5 bits
        output_12bits : out STD_LOGIC_VECTOR(11 downto 0) --salida de 12 bits (7+5)
    );
end concatenator_7_5;

architecture behavioral of concatenator_7_5 is
begin
    --concatenacion: los 7 bits mas significativos, seguidos de los 5 bits menos significativos
    output_12bits <= input_7bits & input_5bits;
end behavioral;
