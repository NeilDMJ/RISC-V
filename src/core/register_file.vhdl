library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity BancoDeRegistros is
    port (
        CLK : in STD_LOGIC;                        -- Clock signal / Señal de reloj
        di  : in std_logic_vector(31 downto 0);    -- Data Input / Datos de entrada para escritura
        a2  : in std_logic_vector(4 downto 0);     -- Address 2 / Dirección del registro para puerto 2 (rs2)
        a1  : in std_logic_vector(4 downto 0);     -- Address 1 / Dirección del registro para puerto 1 (rs1)
        ad  : in std_logic_vector(4 downto 0);     -- Address Destination / Dirección del registro destino (rd)
        we  : in STD_LOGIC;                        -- Write Enable / Habilitación de escritura
        do2 : out std_logic_vector(31 downto 0);   -- Data Output 2 / Datos de salida del puerto 2 (rs2_data)
        do1 : out std_logic_vector(31 downto 0)    -- Data Output 1 / Datos de salida del puerto 1 (rs1_data)
        );
end BancoDeRegistros;

architecture BancoDeRegistros of BancoDeRegistros is

    type tipoMemoria is array (0 to 31) of STD_LOGIC_VECTOR(31 downto 0);

signal memoria : tipoMemoria := (
    
    others => "00000000000000000000000000000000");

begin 
    process (CLK)
    begin
        if rising_edge(CLK) then
            if we = '1' and ad /= "00000" then
                memoria(to_integer(unsigned(ad))) <= di;
            end if;
        end if;
    end process;

    do1 <= memoria(to_integer(unsigned(a1)));   -- Salida puerto 1: lee registro rs1
    do2 <= memoria(to_integer(unsigned(a2)));   -- Salida puerto 2: lee registro rs2

end BancoDeRegistros; 

