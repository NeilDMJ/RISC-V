--------------------------------------------------------------------------------
-- Módulo Top-Level del Procesador RISC-V
-- Para uso en Active-HDL como diseño esquemático
-- Implementa el procesador completo con programa de Fibonacci
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity riscv_processor_top is
    port (
        -- Señales de entrada
        clk         : in  STD_LOGIC;                        -- Reloj del sistema
        reset       : in  STD_LOGIC;                        -- Reset del procesador
        
        -- Salidas de monitoreo (opcionales para debugging)
        pc_out      : out STD_LOGIC_VECTOR(31 downto 0);   -- Program Counter actual
        instr_out   : out STD_LOGIC_VECTOR(31 downto 0);   -- Instrucción actual
        alu_res_out : out STD_LOGIC_VECTOR(31 downto 0);   -- Resultado de ALU
        
        -- Señales de estado
        reg_we_out  : out STD_LOGIC;                        -- Write enable de registros
        mem_we_out  : out STD_LOGIC;                        -- Write enable de memoria
        branch_out  : out STD_LOGIC                         -- Indica si se tomó branch
    );
end riscv_processor_top;

architecture structural of riscv_processor_top is
    
    -- ========================================================================
    -- DECLARACIÓN DE COMPONENTES
    -- ========================================================================
    
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
    
    component instruction_memory_fibonacci is
        port (
            addr        : in  STD_LOGIC_VECTOR(31 downto 0);
            instruction : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;
    
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
    
    component ImmExtend is
        port (
            instr   : in STD_LOGIC_VECTOR(31 downto 0);
            imm_src : in STD_LOGIC_VECTOR(1 downto 0);
            imm_ext : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;
    
    component ALU is
        port(
            do1       : in STD_LOGIC_VECTOR(31 downto 0);
            do2       : in STD_LOGIC_VECTOR(31 downto 0);
            op        : in STD_LOGIC_VECTOR(3 downto 0);
            resultado : out STD_LOGIC_VECTOR(31 downto 0);
            zero      : out STD_LOGIC
        );
    end component;
    
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
    -- SEÑALES INTERNAS (BUSES DE INTERCONEXIÓN)
    -- ========================================================================
    
    -- Program Counter
    signal pc_current    : STD_LOGIC_VECTOR(31 downto 0);
    signal pc_next       : STD_LOGIC_VECTOR(31 downto 0);
    signal pc_plus_4     : STD_LOGIC_VECTOR(31 downto 0);
    signal pc_branch     : STD_LOGIC_VECTOR(31 downto 0);
    signal pc_enable     : STD_LOGIC;
    signal pc_load       : STD_LOGIC;
    
    -- Instruction Memory
    signal instruction   : STD_LOGIC_VECTOR(31 downto 0);
    
    -- Campos de instrucción
    signal opcode : STD_LOGIC_VECTOR(6 downto 0);
    signal rs1    : STD_LOGIC_VECTOR(4 downto 0);
    signal rs2    : STD_LOGIC_VECTOR(4 downto 0);
    signal rd     : STD_LOGIC_VECTOR(4 downto 0);
    
    -- Control Signals
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
    
begin
    
    -- ========================================================================
    -- ASIGNACIÓN DE SALIDAS DE MONITOREO
    -- ========================================================================
    pc_out      <= pc_current;
    instr_out   <= instruction;
    alu_res_out <= alu_result;
    reg_we_out  <= ctrl_reg_we;
    mem_we_out  <= ctrl_mem_we;
    branch_out  <= branch_taken;
    
    -- ========================================================================
    -- INSTANCIACIÓN DE COMPONENTES (NETLIST ESTRUCTURAL)
    -- ========================================================================
    
    -- Program Counter
    U_PC: program_counter
        port map (
            clk    => clk,
            reset  => reset,
            enable => pc_enable,
            pc_in  => pc_next,
            load   => pc_load,
            pc_out => pc_current
        );
    
    -- Instruction Memory (ROM con programa Fibonacci)
    U_IMEM: instruction_memory_fibonacci
        port map (
            addr        => pc_current,
            instruction => instruction
        );
    
    -- Decoder (Control Unit)
    U_DECODER: decoder
        port map (
            instr      => instruction,
            reg_we     => ctrl_reg_we,
            mem_we     => ctrl_mem_we,
            alu_src    => ctrl_alu_src,
            mem_to_reg => ctrl_mem_to_reg,
            imm_src    => ctrl_imm_src,
            op         => ctrl_alu_op
        );
    
    -- Register File
    U_REGFILE: BancoDeRegistros
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
    U_IMMEXT: ImmExtend
        port map (
            instr   => instruction,
            imm_src => ctrl_imm_src,
            imm_ext => imm_extended
        );
    
    -- ALU
    U_ALU: ALU
        port map (
            do1       => alu_operand1,
            do2       => alu_operand2,
            op        => ctrl_alu_op,
            resultado => alu_result,
            zero      => alu_zero
        );
    
    -- Data Memory
    U_DMEM: data_mem_simple
        port map (
            clk      => clk,
            we       => ctrl_mem_we,
            addr     => alu_result,
            data_in  => reg_rs2_data,
            data_out => mem_data_out
        );
    
    -- ========================================================================
    -- LÓGICA COMBINACIONAL (DATAPATH)
    -- ========================================================================
    
    -- Decodificación de campos de instrucción
    opcode <= instruction(6 downto 0);
    rs1    <= instruction(19 downto 15);
    rs2    <= instruction(24 downto 20);
    rd     <= instruction(11 downto 7);
    
    -- ALU Operand 1 (siempre rs1)
    alu_operand1 <= reg_rs1_data;
    
    -- MUX: ALU Operand 2 (rs2 o inmediato)
    alu_operand2 <= imm_extended when ctrl_alu_src = '1' else reg_rs2_data;
    
    -- MUX: Write Data (ALU result o Memory data)
    reg_write_data <= mem_data_out when ctrl_mem_to_reg = '1' else alu_result;
    
    -- PC + 4 (siguiente instrucción secuencial)
    pc_plus_4 <= std_logic_vector(unsigned(pc_current) + 4);
    
    -- PC + offset (dirección de branch)
    pc_branch <= std_logic_vector(signed(pc_current) + signed(imm_extended));
    
    -- Detectar instrucción de branch (opcode = 1100011)
    is_branch_instr <= '1' when opcode = "1100011" else '0';
    
    -- Branch taken (branch instruction AND condition true)
    branch_taken <= '1' when (is_branch_instr = '1' and alu_result(0) = '1') else '0';
    
    -- MUX: Next PC (PC+4 o branch target)
    pc_next <= pc_branch when branch_taken = '1' else pc_plus_4;
    
    -- PC control signals
    pc_enable <= '1';  -- Siempre habilitado
    pc_load   <= '1';  -- Siempre cargar nuevo PC
    
end structural;
