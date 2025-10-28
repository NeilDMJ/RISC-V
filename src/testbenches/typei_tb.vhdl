library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_TypeI is
end tb_TypeI;

architecture Behavioral of tb_TypeI is
    -- Componente Decoder
    component Decoder is
        port (
            instr       : in STD_LOGIC_VECTOR(31 downto 0);
            we          : out STD_LOGIC;
            alu_src     : out STD_LOGIC;
            op          : out STD_LOGIC_VECTOR(3 downto 0)
        );
    end component;

    -- Componente ALU
    component ALU is
        port(
            do1       : in STD_LOGIC_VECTOR(31 downto 0);
            do2       : in STD_LOGIC_VECTOR(31 downto 0);
            op        : in STD_LOGIC_VECTOR(3 downto 0);
            resultado : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;

    -- Componente ImmExtend
    component ImmExtend is
        port (
            instr       : in STD_LOGIC_VECTOR(31 downto 0);
            imm_ext     : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;

    -- Señales de prueba
    signal instr      : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal we         : STD_LOGIC;
    signal alu_src    : STD_LOGIC;
    signal op         : STD_LOGIC_VECTOR(3 downto 0);
    signal do1        : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal do2_reg    : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal imm_ext    : STD_LOGIC_VECTOR(31 downto 0);
    signal do2_alu    : STD_LOGIC_VECTOR(31 downto 0);
    signal resultado  : STD_LOGIC_VECTOR(31 downto 0);

    -- Función auxiliar para construir instrucción tipo I
    function make_i_type(
        imm     : std_logic_vector(11 downto 0);
        rs1     : std_logic_vector(4 downto 0);
        func3   : std_logic_vector(2 downto 0);
        rd      : std_logic_vector(4 downto 0);
        opcode  : std_logic_vector(6 downto 0)
    ) return std_logic_vector is
    begin
        return imm & rs1 & func3 & rd & opcode;
    end function;

    -- Función auxiliar para construir instrucción tipo R
    function make_r_type(
        func7   : std_logic_vector(6 downto 0);
        rs2     : std_logic_vector(4 downto 0);
        rs1     : std_logic_vector(4 downto 0);
        func3   : std_logic_vector(2 downto 0);
        rd      : std_logic_vector(4 downto 0);
        opcode  : std_logic_vector(6 downto 0)
    ) return std_logic_vector is
    begin
        return func7 & rs2 & rs1 & func3 & rd & opcode;
    end function;

begin
    -- Instanciación del Decoder
    UUT_Decoder: Decoder
        port map (
            instr   => instr,
            we      => we,
            alu_src => alu_src,
            op      => op
        );

    -- Instanciación del ImmExtend
    UUT_ImmExtend: ImmExtend
        port map (
            instr   => instr,
            imm_ext => imm_ext
        );

    -- Multiplexor: seleccionar entre registro o inmediato
    do2_alu <= imm_ext when alu_src = '1' else do2_reg;

    -- Instanciación de la ALU
    UUT_ALU: ALU
        port map (
            do1       => do1,
            do2       => do2_alu,
            op        => op,
            resultado => resultado
        );

    -- Proceso de estímulos
    stimulus: process
    begin
        -- Valores iniciales en los "registros"
        do1 <= std_logic_vector(to_signed(20, 32));
        do2_reg <= std_logic_vector(to_signed(5, 32));
        wait for 10 ns;

        -- ========== PRUEBAS TIPO I ==========
        
        -- Test 1: ADDI x1, x0, 15 (x1 = 0 + 15 = 15)
        do1 <= std_logic_vector(to_signed(0, 32));
        instr <= make_i_type(
            imm     => "000000001111",  -- 15
            rs1     => "00000",         -- x0
            func3   => "000",           -- ADDI
            rd      => "00001",         -- x1
            opcode  => "0010011"        -- tipo I
        );
        wait for 20 ns;

        -- Test 2: ADDI x2, x1, 10 (usar resultado anterior: 15 + 10 = 25)
        do1 <= std_logic_vector(to_signed(15, 32));
        instr <= make_i_type(
            imm     => "000000001010",  -- 10
            rs1     => "00001",         -- x1
            func3   => "000",           -- ADDI
            rd      => "00010",         -- x2
            opcode  => "0010011"        -- tipo I
        );
        wait for 20 ns;

        -- Test 3: ADDI x3, x0, -5 (inmediato negativo: 0 + (-5) = -5)
        do1 <= std_logic_vector(to_signed(0, 32));
        instr <= make_i_type(
            imm     => "111111111011",  -- -5 en complemento a 2
            rs1     => "00000",         -- x0
            func3   => "000",           -- ADDI
            rd      => "00011",         -- x3
            opcode  => "0010011"        -- tipo I
        );
        wait for 20 ns;

        -- Test 4: SLLI x4, x2, 2 (25 << 2 = 100)
        
        do1 <= std_logic_vector(to_signed(25, 32));
        instr <= make_i_type(
            imm     => "000000000010",  -- shamt = 2
            rs1     => "00010",         -- x2
            func3   => "001",           -- SLLI
            rd      => "00100",         -- x4
            opcode  => "0010011"        -- tipo I
        );
        wait for 20 ns;

        -- Test 5: SLTI x5, x1, 20 (15 < 20 = 1)
        
        do1 <= std_logic_vector(to_signed(15, 32));
        instr <= make_i_type(
            imm     => "000000010100",  -- 20
            rs1     => "00001",         -- x1
            func3   => "010",           -- SLTI
            rd      => "00101",         -- x5
            opcode  => "0010011"        -- tipo I
        );
        wait for 20 ns;

        -- Test 6: SLTI x6, x2, 10 (25 < 10 = 0)
        
        do1 <= std_logic_vector(to_signed(25, 32));
        instr <= make_i_type(
            imm     => "000000001010",  -- 10
            rs1     => "00010",         -- x2
            func3   => "010",           -- SLTI
            rd      => "00110",         -- x6
            opcode  => "0010011"        -- tipo I
        );
        wait for 20 ns;

        -- Test 7: SLTIU x7, x0, 5 (0 < 5 unsigned = 1)
        
        do1 <= std_logic_vector(to_unsigned(0, 32));
        instr <= make_i_type(
            imm     => "000000000101",  -- 5
            rs1     => "00000",         -- x0
            func3   => "011",           -- SLTIU
            rd      => "00111",         -- x7
            opcode  => "0010011"        -- tipo I
        );
        wait for 20 ns;

        -- Test 8: XORI x8, x1, 7 (15 XOR 7 = 8)
        do1 <= std_logic_vector(to_signed(15, 32));
        instr <= make_i_type(
            imm     => "000000000111",  -- 7
            rs1     => "00001",         -- x1
            func3   => "100",           -- XORI
            rd      => "01000",         -- x8
            opcode  => "0010011"        -- tipo I
        );
        wait for 20 ns;

        -- Test 9: SRLI x9, x4, 2 (100 >> 2 = 25)
        do1 <= std_logic_vector(to_signed(100, 32));
        instr <= make_i_type(
            imm     => "000000000010",  -- shamt = 2
            rs1     => "00100",         -- x4
            func3   => "101",           -- SRLI
            rd      => "01001",         -- x9
            opcode  => "0010011"        -- tipo I
        );
        wait for 20 ns;

        -- Test 10: SRAI x10, x3, 1 (-5 >> 1 arit = -3)
        do1 <= std_logic_vector(to_signed(-5, 32));
        instr <= make_i_type(
            imm     => "010000000001",  -- func7=0100000, shamt=1
            rs1     => "00011",         -- x3
            func3   => "101",           -- SRAI
            rd      => "01010",         -- x10
            opcode  => "0010011"        -- tipo I
        );
        wait for 20 ns;

        -- Test 11: ORI x11, x1, 16 (15 OR 16 = 31)
        do1 <= std_logic_vector(to_signed(15, 32));
        instr <= make_i_type(
            imm     => "000000010000",  -- 16
            rs1     => "00001",         -- x1
            func3   => "110",           -- ORI
            rd      => "01011",         -- x11
            opcode  => "0010011"        -- tipo I
        );
        wait for 20 ns;

        -- Test 12: ANDI x12, x2, 7 (25 AND 7 = 1)
        do1 <= std_logic_vector(to_signed(25, 32));
        instr <= make_i_type(
            imm     => "000000000111",  -- 7
            rs1     => "00010",         -- x2
            func3   => "111",           -- ANDI
            rd      => "01100",         -- x12
            opcode  => "0010011"        -- tipo I
        );
        wait for 20 ns;

        
        -- Test 13: ADD x13, x1, x2 (tipo R: 15 + 25 = 40)
        do1 <= std_logic_vector(to_signed(15, 32));
        do2_reg <= std_logic_vector(to_signed(25, 32));
        instr <= make_r_type(
            func7   => "0000000",
            rs2     => "00010",         -- x2
            rs1     => "00001",         -- x1
            func3   => "000",           -- ADD
            rd      => "01101",         -- x13
            opcode  => "0110011"        -- tipo R
        );
        wait for 20 ns;

        -- Test 14: SUB x14, x2, x1 (tipo R: 25 - 15 = 10)
        do1 <= std_logic_vector(to_signed(25, 32));
        do2_reg <= std_logic_vector(to_signed(15, 32));
        instr <= make_r_type(
            func7   => "0100000",
            rs2     => "00001",         -- x1
            rs1     => "00010",         -- x2
            func3   => "000",           -- SUB
            rd      => "01110",         -- x14
            opcode  => "0110011"        -- tipo R
        );
        wait for 20 ns;
        wait;
    end process;

end Behavioral;
