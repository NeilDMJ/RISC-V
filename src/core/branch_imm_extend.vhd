library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;



entity branch_imm_extend is
    port (
        instr         : in  STD_LOGIC_VECTOR(31 downto 0); -- Instrucción RISC-V completa
        branch_offset : out STD_LOGIC_VECTOR(31 downto 0)  -- Offset de salto relativo al PC
    );
end branch_imm_extend;

architecture Behavioral of branch_imm_extend is
    signal imm13 : STD_LOGIC_VECTOR(12 downto 0); -- inmediato B-type reordenado 
begin
    
  	   
    imm13(12)         <= instr(31);               -- bit de signo
    imm13(10 downto 5)<= instr(30 downto 25);
    imm13(4 downto 1) <= instr(11 downto 8);
    imm13(11)         <= instr(7);
    imm13(0)          <= '0';

    -- Extensión de signo a 32 bits
    process(imm13)
    begin
        if imm13(12) = '1' then
            branch_offset <= (31 downto 13 => '1') & imm13;
        else
            branch_offset <= (31 downto 13 => '0') & imm13;
        end if;
    end process;

end Behavioral;