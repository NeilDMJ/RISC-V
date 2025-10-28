library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ALU is
    port(
        do1 : in STD_LOGIC_VECTOR(31 downto 0);
        do2 : in STD_LOGIC_VECTOR(31 downto 0); 
        op  : in STD_LOGIC_VECTOR(3 downto 0);
        resultado : out STD_LOGIC_VECTOR(31 downto 0)
    );
end ALU;

architecture Behavioral of ALU is
    signal sig_do1, sig_do2 : SIGNED(31 downto 0);
    signal resultado_tmp : SIGNED(31 downto 0);
begin

    -- Conversión de entrada
    sig_do1 <= signed(do1);
    sig_do2 <= signed(do2);

    process (sig_do1, sig_do2, op)
    begin
        case(op) is
            when "0000" => -- suma (ADD)
                resultado_tmp <= sig_do1 + sig_do2;

            when "0001" => -- resta (SUB)
                resultado_tmp <= sig_do1 - sig_do2;

            when "0010" => -- desplazamiento lógico a la izquierda (SLL)
                resultado_tmp <= SHIFT_LEFT(sig_do1, to_integer(unsigned(sig_do2(4 downto 0))));

            when "0100" => -- set less than (SLT, signed)
                if sig_do1 < sig_do2 then
                    resultado_tmp <= (others => '0');
                    resultado_tmp(0) <= '1';
                else
                    resultado_tmp <= (others => '0');
                end if;

            when "0110" => -- set less than unsigned (SLTU)
                if unsigned(do1) < unsigned(do2) then
                    resultado_tmp <= (others => '0');
                    resultado_tmp(0) <= '1';
                else
                    resultado_tmp <= (others => '0');
                end if;

            when "1000" => -- XOR
                resultado_tmp <= sig_do1 xor sig_do2;

            when "1010" => -- desplazamiento lógico a la derecha (SRL)
                resultado_tmp <= signed(shift_right(unsigned(sig_do1), to_integer(unsigned(sig_do2(4 downto 0)))));

            when "1011" => -- desplazamiento aritmético a la derecha (SRA)
                resultado_tmp <= SHIFT_RIGHT(sig_do1, to_integer(unsigned(sig_do2(4 downto 0))));  

            when "1100" => -- OR
                resultado_tmp <= sig_do1 or sig_do2;

            when "1110" => -- AND
                resultado_tmp <= sig_do1 and sig_do2;

            when others =>
                resultado_tmp <= (others => '0');
        end case;
    end process;

    -- Conversión de salida
    resultado <= std_logic_vector(resultado_tmp);

end Behavioral;
