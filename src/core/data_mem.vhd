library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity data_mem is
    port (
        clk      : in  std_logic;
        we       : in  std_logic;
        addr     : in  std_logic_vector(31 downto 0); -- dirección en bytes (RV32I)
        data_in  : in  std_logic_vector(31 downto 0); -- palabra de 32 bits
        data_out : out std_logic_vector(31 downto 0)
    );
end entity;

architecture rtl of data_mem is
    -- 16 palabras de 32 bits = 64 bytes
    type mem_t is array (0 to 15) of std_logic_vector(31 downto 0);
    signal mem      : mem_t := (others => (others => '0'));
    signal dout_reg : std_logic_vector(31 downto 0);
    signal word_idx : unsigned(3 downto 0);
begin

    -- Índice de palabra: usamos addr(5 downto 2)
    -- addr es una dirección en bytes, pero solo soportamos accesos alineados a palabra
    word_idx <= unsigned(addr(5 downto 2));

    process(clk)
    begin
        if rising_edge(clk) then
            if we = '1' then
                mem(to_integer(word_idx)) <= data_in;
            end if;
            dout_reg <= mem(to_integer(word_idx));
        end if;
    end process;

    data_out <= dout_reg;

end architecture;