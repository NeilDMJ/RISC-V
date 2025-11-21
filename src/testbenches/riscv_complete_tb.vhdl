library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity riscv_complete_tb is
end riscv_complete_tb;

architecture testbench of riscv_complete_tb is
    -- Componente Decoder
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

    -- Componente Banco de Registros
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

    -- Componente ALU
    component ALU is
        port(
            do1 : in STD_LOGIC_VECTOR(31 downto 0);
            do2 : in STD_LOGIC_VECTOR(31 downto 0);
            op  : in STD_LOGIC_VECTOR(3 downto 0);
            resultado : out STD_LOGIC_VECTOR(31 downto 0);
            zero : out STD_LOGIC
        );
    end component;

    -- Componente Extension de Inmediato
    component ImmExtend is
        port (
            instr   : in STD_LOGIC_VECTOR(31 downto 0);
            imm_src : in STD_LOGIC_VECTOR(1 downto 0);
            imm_ext : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;

    -- Componente Memoria de Datos
    component data_mem_simple is
        port (
            clk      : in  std_logic;
            we       : in  std_logic;
            addr     : in  std_logic_vector(31 downto 0);
            data_in  : in  std_logic_vector(31 downto 0);
            data_out : out std_logic_vector(31 downto 0)
        );
    end component;

    -- Señales de reloj y control
    signal clk : STD_LOGIC := '0';
    signal instruction : STD_LOGIC_VECTOR(31 downto 0);
    
    -- Señales del decoder
    signal reg_we, mem_we, alu_src, mem_to_reg : STD_LOGIC;
    signal imm_src : STD_LOGIC_VECTOR(1 downto 0);
    signal alu_op : STD_LOGIC_VECTOR(3 downto 0);
    
    -- Señales del banco de registros
    signal rs1, rs2, rd : STD_LOGIC_VECTOR(4 downto 0);
    signal rs1_data, rs2_data, write_data : STD_LOGIC_VECTOR(31 downto 0);
    
    -- Señales de la ALU
    signal alu_operand2, alu_result : STD_LOGIC_VECTOR(31 downto 0);
    signal alu_zero : STD_LOGIC;
    
    -- Señales de extension de inmediato
    signal imm_extended : STD_LOGIC_VECTOR(31 downto 0);
    signal imm_s : STD_LOGIC_VECTOR(31 downto 0);
    
    -- Señales de memoria
    signal mem_data_out : STD_LOGIC_VECTOR(31 downto 0);
    
    -- Constantes para las instrucciones del markdown
    constant INSTR_ADD_X3_X1_X2  : STD_LOGIC_VECTOR(31 downto 0) := X"002081B3";
    constant INSTR_SUB_X5_X3_X4  : STD_LOGIC_VECTOR(31 downto 0) := X"404182B3";
    constant INSTR_AND_X7_X5_X6  : STD_LOGIC_VECTOR(31 downto 0) := X"0062F3B3";
    constant INSTR_ADDI_X8_X0_10 : STD_LOGIC_VECTOR(31 downto 0) := X"00A00413";
    constant INSTR_XORI_X9_X8_15 : STD_LOGIC_VECTOR(31 downto 0) := X"00F44493";
    constant INSTR_ORI_X10_X9_7  : STD_LOGIC_VECTOR(31 downto 0) := X"0074E513";
    constant INSTR_LW_X11_0_X8   : STD_LOGIC_VECTOR(31 downto 0) := X"00042583";
    constant INSTR_LW_X12_4_X10  : STD_LOGIC_VECTOR(31 downto 0) := X"00452603";
    constant INSTR_SW_X11_0_X8   : STD_LOGIC_VECTOR(31 downto 0) := X"00B42023";
    constant INSTR_SW_X12_8_X10  : STD_LOGIC_VECTOR(31 downto 0) := X"00C52423";
    
    -- Periodo del reloj
    constant CLK_PERIOD : time := 10 ns;

begin
    -- Generador de reloj
    clk_process: process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;

    -- Extraccion de campos de la instruccion
    rs1 <= instruction(19 downto 15);
    rs2 <= instruction(24 downto 20);
    rd  <= instruction(11 downto 7);
    
    -- Formacion del inmediato tipo S (concatenar bits [31:25] y [11:7])
    imm_s <= (31 downto 12 => instruction(31)) & instruction(31 downto 25) & instruction(11 downto 7);

    -- Instanciacion del Decoder
    u_decoder: decoder
        port map (
            instr      => instruction,
            reg_we     => reg_we,
            mem_we     => mem_we,
            alu_src    => alu_src,
            mem_to_reg => mem_to_reg,
            imm_src    => imm_src,
            op         => alu_op
        );

    -- Instanciacion del Banco de Registros
    u_regfile: BancoDeRegistros
        port map (
            CLK => clk,
            di  => write_data,
            a2  => rs2,
            a1  => rs1,
            ad  => rd,
            we  => reg_we,
            do2 => rs2_data,
            do1 => rs1_data
        );

    -- Instanciacion de Extension de Inmediato
    u_immext: ImmExtend
        port map (
            instr   => instruction,
            imm_src => imm_src,
            imm_ext => imm_extended
        );

    -- Multiplexor para seleccionar operando 2 de la ALU (registro o inmediato)
    alu_operand2 <= imm_extended when (alu_src = '1' and (imm_src = "00" or imm_src = "10")) else
                    imm_s when (alu_src = '1' and imm_src = "01") else
                    rs2_data;

    -- Instanciacion de la ALU
    u_alu: ALU
        port map (
            do1       => rs1_data,
            do2       => alu_operand2,
            op        => alu_op,
            resultado => alu_result,
            zero      => alu_zero
        );

    -- Instanciacion de Memoria de Datos
    u_datamem: data_mem_simple
        port map (
            clk      => clk,
            we       => mem_we,
            addr     => alu_result,
            data_in  => rs2_data,
            data_out => mem_data_out
        );

    -- Multiplexor para seleccionar dato a escribir en registro (ALU o memoria)
    write_data <= mem_data_out when mem_to_reg = '1' else alu_result;

    -- Proceso de prueba
    stim_proc: process
    begin
        -- Esperar un ciclo para inicializar
        instruction <= (others => '0');
        wait for CLK_PERIOD;
        
        -- ====== INSTRUCCIONES TIPO R ======
        
        -- 1. ADD x3, x1, x2: x3 = x1 + x2
        -- Primero inicializamos x1=5, x2=3
        instruction <= X"00500093"; -- addi x1, x0, 5
        wait for CLK_PERIOD;
        
        instruction <= X"00300113"; -- addi x2, x0, 3
        wait for CLK_PERIOD;
        
        instruction <= INSTR_ADD_X3_X1_X2; -- add x3, x1, x2 (x3 = 5 + 3 = 8)
        wait for CLK_PERIOD;
        
        -- 2. SUB x5, x3, x4: x5 = x3 - x4
        -- Inicializamos x4=2
        instruction <= X"00200213"; -- addi x4, x0, 2
        wait for CLK_PERIOD;
        
        instruction <= INSTR_SUB_X5_X3_X4; -- sub x5, x3, x4 (x5 = 8 - 2 = 6)
        wait for CLK_PERIOD;
        
        -- 3. AND x7, x5, x6: x7 = x5 AND x6
        -- Inicializamos x6=7
        instruction <= X"00700313"; -- addi x6, x0, 7
        wait for CLK_PERIOD;
        
        instruction <= INSTR_AND_X7_X5_X6; -- and x7, x5, x6 (x7 = 6 AND 7 = 6)
        wait for CLK_PERIOD;
        
        -- ====== INSTRUCCIONES TIPO I ======
        
        -- 4. ADDI x8, x0, 10: x8 = 0 + 10
        instruction <= INSTR_ADDI_X8_X0_10; -- x8 = 10
        wait for CLK_PERIOD;
        
        -- 5. XORI x9, x8, 15: x9 = x8 XOR 15
        instruction <= INSTR_XORI_X9_X8_15; -- x9 = 10 XOR 15 = 5
        wait for CLK_PERIOD;
        
        -- 6. ORI x10, x9, 7: x10 = x9 OR 7
        instruction <= INSTR_ORI_X10_X9_7; -- x10 = 5 OR 7 = 7
        wait for CLK_PERIOD;
        
        -- ====== INSTRUCCIONES TIPO S (STORE) ======
        
        -- 7. SW x11, 0(x8): Mem[x8 + 0] = x11
        -- Primero inicializamos x11=100
        instruction <= X"06400593"; -- addi x11, x0, 100
        wait for CLK_PERIOD;
        
        instruction <= INSTR_SW_X11_0_X8; -- Guardar x11 en Mem[10]
        wait for CLK_PERIOD;
        
        -- 8. SW x12, 8(x10): Mem[x10 + 8] = x12
        -- Inicializamos x12=200
        instruction <= X"0C800613"; -- addi x12, x0, 200
        wait for CLK_PERIOD;
        
        instruction <= INSTR_SW_X12_8_X10; -- Guardar x12 en Mem[15]
        wait for CLK_PERIOD;
        
        -- ====== INSTRUCCIONES TIPO L (LOAD) ======
        
        -- 9. LW x11, 0(x8): x11 = Mem[x8 + 0]
        instruction <= INSTR_LW_X11_0_X8; -- Cargar desde Mem[10] a x11
        wait for CLK_PERIOD;
        wait for CLK_PERIOD; -- Esperar un ciclo adicional para la memoria
        
        -- 10. LW x12, 4(x10): x12 = Mem[x10 + 4]
        -- Primero guardamos un valor en esa direccion
        instruction <= X"15E00693"; -- addi x13, x0, 350
        wait for CLK_PERIOD;
        
        instruction <= X"00D52223"; -- sw x13, 4(x10) - Guardar 350 en Mem[11]
        wait for CLK_PERIOD;
        
        instruction <= INSTR_LW_X12_4_X10; -- Cargar desde Mem[11] a x12
        wait for CLK_PERIOD;
        wait for CLK_PERIOD; -- Esperar un ciclo adicional para la memoria
        
        -- Ciclos adicionales para observar resultados finales
        instruction <= (others => '0');
        wait for CLK_PERIOD * 3;
        
        -- Finalizar simulacion
        report "Simulacion completada exitosamente";
        wait;
    end process;

end testbench;
