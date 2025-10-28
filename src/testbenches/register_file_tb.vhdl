library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity BancoDeRegistros_tb is
end BancoDeRegistros_tb;

architecture test of BancoDeRegistros_tb is
    component BancoDeRegistros
        port (
            CLK : in STD_LOGIC;
            di  : in std_logic_vector(31 downto 0);
            a2  : in std_logic_vector(4 downto 0);
            a1  : in std_logic_vector(4 downto 0);
            ad  : in std_logic_vector(4 downto 0);
            we  : in STD_LOGIC;
            do2 : out std_logic_vector(31 downto 0);
            do1 : out std_logic_vector(31 downto 0)
        );
    end component;

-- signal de prueba
    signal CLK : STD_LOGIC := '0';
    signal di  : std_logic_vector(31 downto 0) := (others => '0');
    signal a2  : std_logic_vector(4 downto 0) := (others => '0');
    signal a1  : std_logic_vector(4 downto 0) := (others => '0');
    signal ad  : std_logic_vector(4 downto 0) := (others => '0');
    signal we  : STD_LOGIC := '0';
    signal do2 : std_logic_vector(31 downto 0);
    signal do1 : std_logic_vector(31 downto 0);

    constant CLK_PERIOD : time := 20 ns;

begin
    uut: BancoDeRegistros
        port map (
            CLK => CLK,
            di  => di,
            a2  => a2,
            a1  => a1,
            ad  => ad,
            we  => we,
            do2 => do2,
            do1 => do1
        );

    clk_process: process
    begin
        CLK <= '0';
        wait for CLK_PERIOD/2;
        CLK <= '1';
        wait for CLK_PERIOD/2;
    end process;

    stimulus: process
    begin

        wait for CLK_PERIOD;
        
        -- escribir en registro 1
        we <= '1';
        ad <= "00001";
        di <= x"12345678";
        wait for CLK_PERIOD;
        
        -- escribir en registro 2
        ad <= "00010";
        di <= x"ABCDEF00";
        wait for CLK_PERIOD;
        
        -- escribir en registro 31
        ad <= "11111";
        di <= x"DEADBEEF";
        wait for CLK_PERIOD;
        
        -- intentar escribir en registro 0
        ad <= "00000";
        di <= x"FFFFFFFF";
        wait for CLK_PERIOD;
        
        -- deshabilitar escritura
        we <= '0';
        wait for CLK_PERIOD;
        
        -- leer registro 1 y registro 2
        a1 <= "00001";
        a2 <= "00010";
        wait for CLK_PERIOD;
        
        -- leer registro 31 y registro 0
        a1 <= "11111";
        a2 <= "00000";
        wait for CLK_PERIOD;
        
        -- leer diferentes registros
        a1 <= "00010";
        a2 <= "00001";
        wait for CLK_PERIOD;
        
        -- escribir mas datos
        we <= '1';
        ad <= "00101";
        di <= x"A5A5A5A5";
        wait for CLK_PERIOD;
        
        ad <= "01010";
        di <= x"5A5A5A5A";
        wait for CLK_PERIOD;
        
        we <= '0';
        a1 <= "00101";
        a2 <= "01010";
        wait for CLK_PERIOD * 3;
        
        wait;
    end process;

end test;