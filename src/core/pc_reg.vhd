library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;



entity pc_reg is
    port (
        clk    : in  STD_LOGIC;                     
        reset  : in  STD_LOGIC;                     
        pc_in  : in  STD_LOGIC_VECTOR(31 downto 0); 
        pc_out : out STD_LOGIC_VECTOR(31 downto 0)  
    );
end pc_reg;

architecture Behavioral of pc_reg is
    signal pc_reg_int : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                
                pc_reg_int <= (others => '0');
            else
                pc_reg_int <= pc_in;
            end if;
        end if;
    end process;

    pc_out <= pc_reg_int;

end Behavioral;