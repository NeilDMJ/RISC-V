library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity completo_top is
    port (
        clk   : in  STD_LOGIC;
        reset : in  STD_LOGIC
    );
end completo_top;

architecture Behavioral of completo_top is

    -- PC e instrucción
    signal pc_value      : STD_LOGIC_VECTOR(31 downto 0);
    signal pc_next       : STD_LOGIC_VECTOR(31 downto 0);
    signal instr         : STD_LOGIC_VECTOR(31 downto 0);

    -- Banco de registros
    signal rs1_addr      : STD_LOGIC_VECTOR(4 downto 0);
    signal rs2_addr      : STD_LOGIC_VECTOR(4 downto 0);
    signal rd_addr       : STD_LOGIC_VECTOR(4 downto 0);
    signal rf_di         : STD_LOGIC_VECTOR(31 downto 0);
    signal rf_do1        : STD_LOGIC_VECTOR(31 downto 0);
    signal rf_do2        : STD_LOGIC_VECTOR(31 downto 0);

    -- Inmediatos tipo I/S
    signal imm12         : STD_LOGIC_VECTOR(11 downto 0);
    signal imm_ext       : STD_LOGIC_VECTOR(31 downto 0);

    -- ALU
    signal alu_b_in      : STD_LOGIC_VECTOR(31 downto 0);
    signal alu_result    : STD_LOGIC_VECTOR(31 downto 0);

    -- Memoria de datos
    signal data_mem_out  : STD_LOGIC_VECTOR(31 downto 0);

    -- Señales de control del decoder
    signal reg_we        : STD_LOGIC;
    signal mem_we        : STD_LOGIC;
    signal alu_src       : STD_LOGIC;
    signal mem_to_reg    : STD_LOGIC;
    signal imm_src       : STD_LOGIC;
    signal alu_op        : STD_LOGIC_VECTOR(3 downto 0);
    signal branch        : STD_LOGIC;
    signal branch_type   : STD_LOGIC_VECTOR(1 downto 0);

    -- Lógica de branch / PC
    signal branch_offset : STD_LOGIC_VECTOR(31 downto 0);
    signal pc_plus4      : STD_LOGIC_VECTOR(31 downto 0);
    signal pc_branch     : STD_LOGIC_VECTOR(31 downto 0);
    signal branch_taken  : STD_LOGIC;

begin
    --------------------------------------------------------------------
    -- 1) Registro de PC
    --------------------------------------------------------------------
    U_PC : entity work.pc_reg
        port map (
            clk    => clk,
            reset  => reset,
            pc_in  => pc_next,
            pc_out => pc_value
        );

    --------------------------------------------------------------------
    -- 2) Memoria de instrucciones
    --------------------------------------------------------------------
    U_IMEM : entity work.instr_mem_simple
        port map (
            addr  => pc_value,
            instr => instr
        );

    --------------------------------------------------------------------
    -- 3) Unidad de control (decoder)
    --------------------------------------------------------------------
    U_DEC : entity work.decoder
        port map (
            instr       => instr,
            reg_we      => reg_we,
            mem_we      => mem_we,
            alu_src     => alu_src,
            mem_to_reg  => mem_to_reg,
            imm_src     => imm_src,
            op          => alu_op,
            branch      => branch,
            branch_type => branch_type
        );

    --------------------------------------------------------------------
    -- 4) Banco de registros
    --------------------------------------------------------------------
    rs1_addr <= instr(19 downto 15);
    rs2_addr <= instr(24 downto 20);
    rd_addr  <= instr(11 downto 7);

    U_RF : entity work.BancoDeRegistros
        port map (
            CLK => clk,
            di  => rf_di,
            a2  => rs2_addr,
            a1  => rs1_addr,
            ad  => rd_addr,
            we  => reg_we,
            do2 => rf_do2,
            do1 => rf_do1
        );

    --------------------------------------------------------------------
    -- 5) Inmediato I/S + ImmExtend (igual que tu diseño)
    --------------------------------------------------------------------
    -- Suposición: concatenas [31:25] & [24:20] como inmediato de 12 bits
    U_CONCAT : entity work.concatenator_7_5
        port map (
            input_7bits   => instr(31 downto 25),
            input_5bits   => instr(24 downto 20),
            output_12bits => imm12
        );

    U_IMMEXT : entity work.ImmExtend
        port map (
            imm_in  => imm12,
            imm_ext => imm_ext
        );

    --------------------------------------------------------------------
    -- 6) MUX de entrada B de la ALU (alu_src)
    --------------------------------------------------------------------
    U_MUX_ALU_B : entity work.mux2to1
        port map (
            input0 => rf_do2,
            input1 => imm_ext,
            sel    => alu_src,
            output => alu_b_in
        );

    --------------------------------------------------------------------
    -- 7) ALU
    --------------------------------------------------------------------
    U_ALU : entity work.ALU
        port map (
            do1       => rf_do1,
            do2       => alu_b_in,
            op        => alu_op,
            resultado => alu_result
        );

    --------------------------------------------------------------------
    -- 8) Memoria de datos
    --------------------------------------------------------------------
    U_DMEM : entity work.data_mem_simple
        port map (
            clk      => clk,
            we       => mem_we,
            addr     => alu_result,
            data_in  => rf_do2,
            data_out => data_mem_out
        );

    --------------------------------------------------------------------
    -- 9) MUX de escritura al banco de registros (mem_to_reg)
    --------------------------------------------------------------------
    U_MUX_WB : entity work.mux2to1
        port map (
            input0 => alu_result,
            input1 => data_mem_out,
            sel    => mem_to_reg,
            output => rf_di
        );

    --------------------------------------------------------------------
    -- 10) Inmediato de branch (Orden & Sign Extend)
    --------------------------------------------------------------------
    U_BRANCH_IMM : entity work.branch_imm_extend
        port map (
            instr         => instr,
            branch_offset => branch_offset
        );

    --------------------------------------------------------------------
    -- 11) Unidad de branch (beq / blt / bltu)
    --------------------------------------------------------------------
    U_BRANCH_UNIT : entity work.branch_unit
        port map (
            rs1          => rf_do1,
            rs2          => rf_do2,
            branch       => branch,
            branch_type  => branch_type,
            branch_taken => branch_taken
        );

    --------------------------------------------------------------------
    -- 12) Sumadores de PC y MUX del PC (esto es lo que te faltaba)
    --------------------------------------------------------------------
    -- Sumador PC + 4
    pc_plus4  <= std_logic_vector(unsigned(pc_value) + 4);

    -- Sumador PC + offset de branch
    pc_branch <= std_logic_vector(unsigned(pc_value) + unsigned(branch_offset));

    -- MUX PC: si branch_taken='1' -> PC+offset, si no -> PC+4
    process(pc_plus4, pc_branch, branch_taken)
    begin
        if branch_taken = '1' then
            pc_next <= pc_branch;
        else
            pc_next <= pc_plus4;
        end if;
    end process;

end Behavioral;