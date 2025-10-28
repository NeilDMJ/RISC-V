library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity data_mem_simple is
    port (
        clk      : in  std_logic;
        we       : in  std_logic;
        addr     : in  std_logic_vector(31 downto 0);
        data_in  : in  std_logic_vector(31 downto 0); -- Palabra de 32 bits
        data_out : out std_logic_vector(31 downto 0)
    );
end entity;

architecture rtl of data_mem_simple is
    type mem_t is array (0 to 15) of std_logic_vector(31 downto 0); --16 palabras de 32 bits cada una
    signal mem : mem_t := (others => (others => '0'));
    signal dout_reg : std_logic_vector(31 downto 0);
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if we = '1' then
                mem(to_integer(unsigned(addr(3 downto 0)))) <= data_in;
            end if;
            dout_reg <= mem(to_integer(unsigned(addr(3 downto 0))));
        end if;
    end process;

    data_out <= dout_reg;
end architecture;
