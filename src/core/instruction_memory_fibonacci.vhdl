library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity instruction_memory_fibonacci is
    port (
        addr        : in  STD_LOGIC_VECTOR(31 downto 0);  -- Dirección de la instrucción (PC)
        instruction : out STD_LOGIC_VECTOR(31 downto 0)   -- Instrucción de 32 bits
    );
end instruction_memory_fibonacci;

architecture behavioral of instruction_memory_fibonacci is
    -- Tipo de memoria: array de 256 instrucciones de 32 bits (1 KB)
    type mem_type is array (0 to 255) of STD_LOGIC_VECTOR(31 downto 0);
    
    -- Memoria de instrucciones con programa de Fibonacci
    signal mem : mem_type := (
        -- PROGRAMA FIBONACCI: Calcula los primeros 10 números de Fibonacci
        -- y los almacena en memoria
        
        -- Inicialización (direcciones 0x00 - 0x10)
        0  => X"00A00093",  -- 0x00: addi x1, x0, 10      | n = 10
        1  => X"00000313",  -- 0x04: addi x6, x0, 0       | base_addr = 0
        2  => X"00000393",  -- 0x08: addi x7, x0, 0       | offset = 0
        3  => X"00000113",  -- 0x0C: addi x2, x0, 0       | fib(n-2) = 0
        4  => X"00100193",  -- 0x10: addi x3, x0, 1       | fib(n-1) = 1
        
        -- Guardar casos base (direcciones 0x14 - 0x24)
        5  => X"00232023",  -- 0x14: sw x2, 0(x6)         | Mem[0] = 0
        6  => X"00438393",  -- 0x18: addi x7, x7, 4       | offset = 4
        7  => X"00730433",  -- 0x1C: add x8, x6, x7       | x8 = base + offset
        8  => X"00342023",  -- 0x20: sw x3, 0(x8)         | Mem[4] = 1
        9  => X"00200293",  -- 0x24: addi x5, x0, 2       | contador = 2
        
        -- LOOP: Calcular fibonacci (direcciones 0x28 - 0x48)
        10 => X"0012D463",  -- 0x28: bge x5, x1, 36       | if (cont >= n) goto end (PC+36=0x4C)
        11 => X"00218233",  -- 0x2C: add x4, x3, x2       | fib(n) = fib(n-1) + fib(n-2)
        12 => X"00438393",  -- 0x30: addi x7, x7, 4       | offset += 4
        13 => X"00730433",  -- 0x34: add x8, x6, x7       | x8 = base + offset
        14 => X"00442023",  -- 0x38: sw x4, 0(x8)         | Mem[offset] = fib(n)
        15 => X"003000B3",  -- 0x3C: add x2, x0, x3       | fib(n-2) = fib(n-1)
        16 => X"00400133",  -- 0x40: add x3, x0, x4       | fib(n-1) = fib(n)
        17 => X"00128293",  -- 0x44: addi x5, x5, 1       | contador++
        18 => X"FE000063",  -- 0x48: beq x0, x0, -32      | goto loop (PC-32=0x28)
        
        -- END: Programa terminado (dirección 0x4C)
        19 => X"00000013",  -- 0x4C: addi x0, x0, 0       | NOP (end)
        
        -- Resto de la memoria inicializada con NOP
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
            instruction <= X"00000013";  -- NOP si fuera de rango
        end if;
    end process;

end behavioral;
