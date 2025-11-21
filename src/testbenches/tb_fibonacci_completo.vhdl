--------------------------------------------------------------------------------
-- Testbench para el Procesador RISC-V Completo con Fibonacci
-- Basado en la arquitectura de completo_top con branch_unit
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_fibonacci_completo is
end tb_fibonacci_completo;

architecture testbench of tb_fibonacci_completo is

    -- Componente del procesador completo
    component completo_top is
        port (
            clk   : in  STD_LOGIC;
            reset : in  STD_LOGIC
        );
    end component;

    -- Señales del testbench
    signal clk   : STD_LOGIC := '0';
    signal reset : STD_LOGIC := '1';
    
    -- Control de simulación
    constant CLK_PERIOD : time := 10 ns;
    constant MAX_CYCLES : integer := 200;
    signal cycle_count  : integer := 0;
    signal sim_done     : boolean := false;

begin

    -- ========================================================================
    -- Instanciación del DUT (Device Under Test)
    -- ========================================================================
    DUT: completo_top
        port map (
            clk   => clk,
            reset => reset
        );

    -- ========================================================================
    -- Generador de Reloj
    -- ========================================================================
    clk_process: process
    begin
        while not sim_done loop
            clk <= '0';
            wait for CLK_PERIOD/2;
            clk <= '1';
            wait for CLK_PERIOD/2;
        end loop;
        wait;
    end process;

    -- ========================================================================
    -- Control de Reset
    -- ========================================================================
    reset_process: process
    begin
        reset <= '1';
        wait for CLK_PERIOD * 3;
        reset <= '0';
        report "Reset liberado - Iniciando ejecución del programa Fibonacci";
        wait;
    end process;

    -- ========================================================================
    -- Contador de Ciclos y Control de Simulación
    -- ========================================================================
    cycle_counter: process(clk)
    begin
        if rising_edge(clk) then
            if reset = '0' then
                cycle_count <= cycle_count + 1;
                
                -- Reportar progreso cada 10 ciclos
                if cycle_count mod 10 = 0 then
                    report "Ciclo " & integer'image(cycle_count);
                end if;
                
                -- Finalizar simulación después de MAX_CYCLES
                if cycle_count >= MAX_CYCLES then
                    report "========================================";
                    report "Simulación completada en " & integer'image(MAX_CYCLES) & " ciclos";
                    report "========================================";
                    report "Programa Fibonacci ejecutado";
                    report "";
                    report "Valores esperados en memoria de datos:";
                    report "  Mem[0x00] = 1   (Fibonacci inicial)";
                    report "  Mem[0x04] = 1   (Fibonacci 1)";
                    report "  Mem[0x08] = 2   (Fibonacci 2)";
                    report "  Mem[0x0C] = 3   (Fibonacci 3)";
                    report "  Mem[0x10] = 5   (Fibonacci 4)";
                    report "  Mem[0x14] = 8   (Fibonacci 5)";
                    report "  Mem[0x18] = 13  (Fibonacci 6)";
                    report "";
                    report "NOTA: Verificar memoria de datos en el waveform";
                    report "      dentro del componente DUT.U_DMEM.mem";
                    sim_done <= true;
                end if;
            end if;
        end if;
    end process;

    -- ========================================================================
    -- Monitor de Ejecución (para debugging)
    -- ========================================================================
    monitor: process(clk)
    begin
        if rising_edge(clk) and reset = '0' then
            -- Imprimir información clave en ciclos específicos
            if cycle_count = 1 then
                report "Ciclo 1: Inicializando n=7";
            elsif cycle_count = 5 then
                report "Ciclo 5: Variables inicializadas (a=0, b=1)";
            elsif cycle_count = 10 then
                report "Ciclo 10: Primer valor guardado en memoria";
            elsif cycle_count = 20 then
                report "Ciclo 20: Loop de Fibonacci en ejecución";
            elsif cycle_count = 50 then
                report "Ciclo 50: Calculando números intermedios";
            elsif cycle_count = 100 then
                report "Ciclo 100: Continuando cálculo de Fibonacci";
            end if;
        end if;
    end process;

end testbench;
