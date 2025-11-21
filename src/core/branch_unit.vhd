library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Unidad de decisión de salto condicional.
-- Implementa beq, blt (signed) y bltu (unsigned) con un "MUX" de tipo de branch.
--
-- Suposición necesaria:
--  branch_type = "00" -> BEQ
--  branch_type = "01" -> BLT
--  branch_type = "10" -> BLTU

entity branch_unit is
    port (
        rs1          : in  STD_LOGIC_VECTOR(31 downto 0); -- operando 1 (tipo xN)
        rs2          : in  STD_LOGIC_VECTOR(31 downto 0); -- operando 2
        branch       : in  STD_LOGIC;                     -- '1' si la instrucción es branch
        branch_type  : in  STD_LOGIC_VECTOR(1 downto 0);  -- selecciona beq/blt/bltu
        branch_taken : out STD_LOGIC                      -- '1' si se toma el salto
    );
end branch_unit;

architecture Behavioral of branch_unit is
    signal beq_cond  : STD_LOGIC;
    signal blt_cond  : STD_LOGIC;
    signal bltu_cond : STD_LOGIC;
    signal cond_sel  : STD_LOGIC;
begin
    -- Comparación BEQ
    beq_cond <= '1' when rs1 = rs2 else '0';

    -- Comparación BLT 
    blt_cond <= '1' when signed(rs1) < signed(rs2) else '0';

    -- Comparación BLTU 
    bltu_cond <= '1' when unsigned(rs1) < unsigned(rs2) else '0';

    -- MUX de tipo de branch 
    process(branch_type, beq_cond, blt_cond, bltu_cond)
    begin
        case branch_type is
            when "00" =>  -- beq
                cond_sel <= beq_cond;
            when "01" =>  -- blt
                cond_sel <= blt_cond;
            when "10" =>  -- bltu
                cond_sel <= bltu_cond;
            when others =>
                cond_sel <= '0';
        end case;
    end process;

    -- Salida final
    branch_taken <= branch and cond_sel;

end Behavioral;