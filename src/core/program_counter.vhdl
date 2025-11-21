library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity program_counter is
    port (
        clk    : in  STD_LOGIC;                       -- Señal de reloj
        reset  : in  STD_LOGIC;                       -- Reset asíncrono (activo en alto)
        enable : in  STD_LOGIC;                       -- Habilitación del contador (1=contar, 0=mantener)
        pc_in  : in  STD_LOGIC_VECTOR(31 downto 0);  -- Entrada para saltos/branches (opcional)
        load   : in  STD_LOGIC;                       -- Señal para cargar pc_in (1=cargar, 0=incrementar)
        pc_out : out STD_LOGIC_VECTOR(31 downto 0)   -- Dirección de la instrucción actual
    );
end program_counter;

architecture behavioral of program_counter is
    signal pc_reg : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
begin
    process(clk, reset)
    begin
        if reset = '1' then
            -- Reset asíncrono: PC = 0
            pc_reg <= (others => '0');
        elsif rising_edge(clk) then
            if enable = '1' then
                if load = '1' then
                    -- Cargar dirección específica (para saltos/branches)
                    pc_reg <= pc_in;
                else
                    -- Incrementar PC en 4 bytes (siguiente instrucción)
                    pc_reg <= std_logic_vector(unsigned(pc_reg) + 4);
                end if;
            end if;
            -- Si enable = '0', mantener el valor actual
        end if;
    end process;

    -- Salida del PC
    pc_out <= pc_reg;

end behavioral;
