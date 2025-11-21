library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity instruction_memory is
    port (
        addr        : in  STD_LOGIC_VECTOR(31 downto 0);  -- Dirección de la instrucción (PC)
        instruction : out STD_LOGIC_VECTOR(31 downto 0)   -- Instrucción de 32 bits
    );
end instruction_memory;

architecture behavioral of instruction_memory is
    -- Tipo de memoria: array de 256 instrucciones de 32 bits (1 KB)
    type mem_type is array (0 to 255) of STD_LOGIC_VECTOR(31 downto 0);
    
    -- Memoria de instrucciones inicializada con las instrucciones de prueba
    signal mem : mem_type := (
        -- Programa de prueba (direcciones 0-39 en bytes, 0-9 en palabras)
        0  => X"00500093",  -- addi x1, x0, 5        (inicializar x1=5)
        1  => X"00300113",  -- addi x2, x0, 3        (inicializar x2=3)
        2  => X"002081B3",  -- add x3, x1, x2        (x3 = 5 + 3 = 8)
        3  => X"00200213",  -- addi x4, x0, 2        (inicializar x4=2)
        4  => X"404182B3",  -- sub x5, x3, x4        (x5 = 8 - 2 = 6)
        5  => X"00700313",  -- addi x6, x0, 7        (inicializar x6=7)
        6  => X"0062F3B3",  -- and x7, x5, x6        (x7 = 6 AND 7 = 6)
        7  => X"00A00413",  -- addi x8, x0, 10       (x8 = 10)
        8  => X"00F44493",  -- xori x9, x8, 15       (x9 = 10 XOR 15 = 5)
        9  => X"0074E513",  -- ori x10, x9, 7        (x10 = 5 OR 7 = 7)
        10 => X"06400593",  -- addi x11, x0, 100     (inicializar x11=100)
        11 => X"00B42023",  -- sw x11, 0(x8)         (Mem[10] = 100)
        12 => X"0C800613",  -- addi x12, x0, 200     (inicializar x12=200)
        13 => X"00C52423",  -- sw x12, 8(x10)        (Mem[15] = 200)
        14 => X"00042583",  -- lw x11, 0(x8)         (x11 = Mem[10] = 100)
        15 => X"15E00693",  -- addi x13, x0, 350     (inicializar x13=350)
        16 => X"00D52223",  -- sw x13, 4(x10)        (Mem[11] = 350)
        17 => X"00452603",  -- lw x12, 4(x10)        (x12 = Mem[11] = 350)
        
        -- Resto de la memoria inicializada con NOP (addi x0, x0, 0)
        others => X"00000013"  -- NOP
    );
    
begin
    -- La dirección se divide por 4 para obtener el índice (word-aligned)
    process(addr)
        variable word_addr : integer;
    begin
        -- Convertir dirección de byte a dirección de palabra (dividir por 4)
        word_addr := to_integer(unsigned(addr(9 downto 2)));
        -- Verificar que la dirección esté dentro del rango
        if word_addr < 256 then
            instruction <= mem(word_addr);
        else
            instruction <= X"00000013";
        end if;
    end process;

end behavioral;
