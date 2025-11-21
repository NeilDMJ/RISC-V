--------------------------------------------------------------------------------
-- Testbench Esquemático del Procesador RISC-V
-- Implementación: Algoritmo de Fibonacci
-- 
-- Este testbench instancia todos los componentes del procesador de forma
-- esquemática (como un diagrama de bloques en VHDL) y ejecuta el programa
-- de Fibonacci que calcula los primeros 10 números de la secuencia.
--
-- Arquitectura del Procesador:
--   ????????????????
--   ? Program      ?
--   ? Counter (PC) ??????????
--   ????????????????        ?
--          ?                ?
--          ?                ?
--   ????????????????  ????????????????
--   ? Instruction  ?  ?   Decoder    ?
--   ?   Memory     ?  ?              ?
--   ????????????????  ????????????????
--          ?                ?
--          ?                ?
--          ?         (señales de control)
--          ?                ?
--          ???????????????????????????
--                   ?                ?
--            ????????????????  ????????????
--            ?  Register    ?  ? Imm      ?
--            ?    File      ?  ? Extend   ?
--            ????????????????  ????????????
--                   ?                ?
--                   ??????????????????
--                            ?
--                       ???????????
--                       ?   ALU   ?
--                       ???????????
--                            ?
--                            ?
--                   ????????????????
--                   ? Data Memory  ?
--                   ????????????????
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fibonacci_processor_tb is
end fibonacci_processor_tb;

architecture structural of fibonacci_processor_tb is
    
    -- ========================================================================
    -- DECLARACIÓN DE COMPONENTES
    -- ========================================================================
    
    -- Componente: Program Counter
    component program_counter is
        port (
            clk    : in  STD_LOGIC;
            reset  : in  STD_LOGIC;
            enable : in  STD_LOGIC;
            pc_in  : in  STD_LOGIC_VECTOR(31 downto 0);
            load   : in  STD_LOGIC;
            pc_out : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;
    
    -- Componente: Instruction Memory
    component instruction_memory_fibonacci is
        port (
            addr        : in  STD_LOGIC_VECTOR(31 downto 0);
            instruction : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;
    
    -- Componente: Decoder
    component decoder is
        port (
            instr       : in STD_LOGIC_VECTOR(31 downto 0);
            reg_we      : out STD_LOGIC;
            mem_we      : out STD_LOGIC;
            alu_src     : out STD_LOGIC;
            mem_to_reg  : out STD_LOGIC;
            imm_src     : out STD_LOGIC_VECTOR(1 downto 0);
            op          : out STD_LOGIC_VECTOR(3 downto 0)
        );
    end component;
    
    -- Componente: Register File (Banco de Registros)
    component BancoDeRegistros is
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
    
    -- Componente: Immediate Extender
    component ImmExtend is
        port (
            instr   : in STD_LOGIC_VECTOR(31 downto 0);
            imm_src : in STD_LOGIC_VECTOR(1 downto 0);
            imm_ext : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;
    
    -- Componente: ALU
    component ALU is
        port(
            do1       : in STD_LOGIC_VECTOR(31 downto 0);
            do2       : in STD_LOGIC_VECTOR(31 downto 0);
            op        : in STD_LOGIC_VECTOR(3 downto 0);
            resultado : out STD_LOGIC_VECTOR(31 downto 0);
            zero      : out STD_LOGIC
        );
    end component;
    
    -- Componente: Data Memory
    component data_mem_simple is
        port (
            clk      : in  std_logic;
            we       : in  std_logic;
            addr     : in  std_logic_vector(31 downto 0);
            data_in  : in  std_logic_vector(31 downto 0);
            data_out : out std_logic_vector(31 downto 0)
        );
    end component;
    
    -- ========================================================================
    -- SEÑALES DE INTERCONEXIÓN (BUSES)
    -- ========================================================================
    
    -- Reloj y Reset
    signal clk   : STD_LOGIC := '0';
    signal reset : STD_LOGIC := '1';
    
    -- Program Counter
    signal pc_current    : STD_LOGIC_VECTOR(31 downto 0);
    signal pc_next       : STD_LOGIC_VECTOR(31 downto 0);
    signal pc_plus_4     : STD_LOGIC_VECTOR(31 downto 0);
    signal pc_branch     : STD_LOGIC_VECTOR(31 downto 0);
    signal pc_enable     : STD_LOGIC := '1';
    signal pc_load       : STD_LOGIC;
    
    -- Instruction Memory
    signal instruction   : STD_LOGIC_VECTOR(31 downto 0);
    
    -- Campos de la instrucción
    signal opcode : STD_LOGIC_VECTOR(6 downto 0);
    signal rs1    : STD_LOGIC_VECTOR(4 downto 0);
    signal rs2    : STD_LOGIC_VECTOR(4 downto 0);
    signal rd     : STD_LOGIC_VECTOR(4 downto 0);
    signal func3  : STD_LOGIC_VECTOR(2 downto 0);
    signal func7  : STD_LOGIC_VECTOR(6 downto 0);
    
    -- Señales de Control del Decoder
    signal ctrl_reg_we      : STD_LOGIC;
    signal ctrl_mem_we      : STD_LOGIC;
    signal ctrl_alu_src     : STD_LOGIC;
    signal ctrl_mem_to_reg  : STD_LOGIC;
    signal ctrl_imm_src     : STD_LOGIC_VECTOR(1 downto 0);
    signal ctrl_alu_op      : STD_LOGIC_VECTOR(3 downto 0);
    
    -- Register File
    signal reg_rs1_data     : STD_LOGIC_VECTOR(31 downto 0);
    signal reg_rs2_data     : STD_LOGIC_VECTOR(31 downto 0);
    signal reg_write_data   : STD_LOGIC_VECTOR(31 downto 0);
    
    -- Immediate Extender
    signal imm_extended     : STD_LOGIC_VECTOR(31 downto 0);
    
    -- ALU
    signal alu_operand1     : STD_LOGIC_VECTOR(31 downto 0);
    signal alu_operand2     : STD_LOGIC_VECTOR(31 downto 0);
    signal alu_result       : STD_LOGIC_VECTOR(31 downto 0);
    signal alu_zero         : STD_LOGIC;
    
    -- Data Memory
    signal mem_data_out     : STD_LOGIC_VECTOR(31 downto 0);
    
    -- Branch Control
    signal branch_taken     : STD_LOGIC;
    signal is_branch_instr  : STD_LOGIC;
    
    -- Constantes
    constant CLK_PERIOD : time := 10 ns;
    constant MAX_CYCLES : integer := 150;  -- Máximo de ciclos para ejecutar Fibonacci
    
    -- Contadores
    signal cycle_count : integer := 0;
    
begin
    
    -- ========================================================================
    -- GENERADOR DE RELOJ
    -- ========================================================================
    clk_process: process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;
    
    -- ========================================================================
    -- CONTROL DE RESET
    -- ========================================================================
    reset_process: process
    begin
        reset <= '1';
        wait for CLK_PERIOD * 2;
        reset <= '0';
        wait;
    end process;
    
    -- ========================================================================
    -- CONTADOR DE CICLOS
    -- ========================================================================
    cycle_counter: process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                cycle_count <= 0;
            else
                cycle_count <= cycle_count + 1;
                
                -- Detener simulación después de MAX_CYCLES
                if cycle_count >= MAX_CYCLES then
                    report "Simulación completada después de " & integer'image(MAX_CYCLES) & " ciclos";
                    report "Fibonacci completo. Verificar resultados en Data Memory.";
                    std.env.stop;
                end if;
            end if;
        end if;
    end process;
    
    -- ========================================================================
    -- INSTANCIACIÓN DE COMPONENTES (ESTRUCTURA ESQUEMÁTICA)
    -- ========================================================================
    
    -- Program Counter
    PC: program_counter
        port map (
            clk    => clk,
            reset  => reset,
            enable => pc_enable,
            pc_in  => pc_next,
            load   => pc_load,
            pc_out => pc_current
        );
    
    -- Instruction Memory
    IMEM: instruction_memory_fibonacci
        port map (
            addr        => pc_current,
            instruction => instruction
        );
    
    -- Decoder (Unidad de Control)
    CTRL: decoder
        port map (
            instr      => instruction,
            reg_we     => ctrl_reg_we,
            mem_we     => ctrl_mem_we,
            alu_src    => ctrl_alu_src,
            mem_to_reg => ctrl_mem_to_reg,
            imm_src    => ctrl_imm_src,
            op         => ctrl_alu_op
        );
    
    -- Register File (Banco de Registros)
    REGFILE: BancoDeRegistros
        port map (
            CLK => clk,
            di  => reg_write_data,
            a2  => rs2,
            a1  => rs1,
            ad  => rd,
            we  => ctrl_reg_we,
            do2 => reg_rs2_data,
            do1 => reg_rs1_data
        );
    
    -- Immediate Extender
    IMMEXT: ImmExtend
        port map (
            instr   => instruction,
            imm_src => ctrl_imm_src,
            imm_ext => imm_extended
        );
    
    -- ALU (Unidad Aritmético-Lógica)
    ALU_UNIT: ALU
        port map (
            do1       => alu_operand1,
            do2       => alu_operand2,
            op        => ctrl_alu_op,
            resultado => alu_result,
            zero      => alu_zero
        );
    
    -- Data Memory
    DMEM: data_mem_simple
        port map (
            clk      => clk,
            we       => ctrl_mem_we,
            addr     => alu_result,
            data_in  => reg_rs2_data,
            data_out => mem_data_out
        );
    
    -- ========================================================================
    -- LÓGICA COMBINACIONAL (MULTIPLEXORES Y SUMADORES)
    -- ========================================================================
    
    -- Decodificación de campos de la instrucción
    opcode <= instruction(6 downto 0);
    rs1    <= instruction(19 downto 15);
    rs2    <= instruction(24 downto 20);
    rd     <= instruction(11 downto 7);
    func3  <= instruction(14 downto 12);
    func7  <= instruction(31 downto 25);
    
    -- Operando 1 de la ALU (siempre viene de rs1)
    alu_operand1 <= reg_rs1_data;
    
    -- MUX: Operando 2 de la ALU (rs2 o inmediato)
    alu_operand2 <= imm_extended when ctrl_alu_src = '1' else reg_rs2_data;
    
    -- MUX: Dato a escribir en registro (resultado ALU o dato de memoria)
    reg_write_data <= mem_data_out when ctrl_mem_to_reg = '1' else alu_result;
    
    -- Cálculo de PC + 4
    pc_plus_4 <= std_logic_vector(unsigned(pc_current) + 4);
    
    -- Cálculo de dirección de branch (PC + offset)
    pc_branch <= std_logic_vector(signed(pc_current) + signed(imm_extended));
    
    -- Detectar si es una instrucción de branch
    is_branch_instr <= '1' when opcode = "1100011" else '0';
    
    -- Branch se toma si es instrucción branch Y la condición se cumple
    branch_taken <= '1' when (is_branch_instr = '1' and alu_result(0) = '1') else '0';
    
    -- MUX: Siguiente PC (PC+4 o dirección de branch)
    pc_next <= pc_branch when branch_taken = '1' else pc_plus_4;
    
    -- Control de carga de PC (siempre cargamos el siguiente PC)
    pc_load <= '1';
    
    -- ========================================================================
    -- PROCESO DE MONITOREO Y DEBUGGING
    -- ========================================================================
    monitor: process(clk)
    begin
        if rising_edge(clk) and reset = '0' then
            -- Imprimir estado en ciclos clave
            if cycle_count < 5 or cycle_count mod 10 = 0 then
                report "Ciclo " & integer'image(cycle_count) & 
                       " | PC: 0x" & to_hstring(pc_current) &
                       " | Instr: 0x" & to_hstring(instruction);
            end if;
            
            -- Detectar cuando se escriben valores en memoria (fibonacci)
            if ctrl_mem_we = '1' then
                report "SW: Mem[" & to_hstring(alu_result) & "] = " & 
                       integer'image(to_integer(signed(reg_rs2_data)));
            end if;
            
            -- Detectar branches tomados
            if branch_taken = '1' then
                report "BRANCH TAKEN: PC = 0x" & to_hstring(pc_current) & 
                       " -> 0x" & to_hstring(pc_branch);
            end if;
        end if;
    end process;
    
    -- ========================================================================
    -- VERIFICACIÓN FINAL DE RESULTADOS
    -- ========================================================================
    verify: process
    begin
        -- Esperar a que el programa termine
        wait for CLK_PERIOD * MAX_CYCLES;
        
        report "==========================================";
        report "  VERIFICACIÓN DE RESULTADOS FIBONACCI";
        report "==========================================";
        
        -- Los valores deberían estar en Data Memory
        -- Esta verificación se puede hacer inspeccionando las señales
        
        report "Programa completado. Verificar señales de Data Memory en waveform.";
        report "Valores esperados:";
        report "  Mem[0x00] = 0   (fib 0)";
        report "  Mem[0x04] = 1   (fib 1)";
        report "  Mem[0x08] = 1   (fib 2)";
        report "  Mem[0x0C] = 2   (fib 3)";
        report "  Mem[0x10] = 3   (fib 4)";
        report "  Mem[0x14] = 5   (fib 5)";
        report "  Mem[0x18] = 8   (fib 6)";
        report "  Mem[0x1C] = 13  (fib 7)";
        report "  Mem[0x20] = 21  (fib 8)";
        report "  Mem[0x24] = 34  (fib 9)";
        
        wait;
    end process;
    
end structural;
