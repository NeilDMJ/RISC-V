library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity branch_tb is
end branch_tb;

architecture testbench of branch_tb is
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

    -- Componente ALU
    component ALU is
        port(
            do1       : in STD_LOGIC_VECTOR(31 downto 0);
            do2       : in STD_LOGIC_VECTOR(31 downto 0);
            op        : in STD_LOGIC_VECTOR(3 downto 0);
            resultado : out STD_LOGIC_VECTOR(31 downto 0);
            zero      : out STD_LOGIC
        );
    end component;

    -- Señales
    signal instruction : STD_LOGIC_VECTOR(31 downto 0);
    signal reg_we, mem_we, alu_src, mem_to_reg : STD_LOGIC;
    signal imm_src : STD_LOGIC_VECTOR(1 downto 0);
    signal alu_op : STD_LOGIC_VECTOR(3 downto 0);
    signal rs1_data, rs2_data : STD_LOGIC_VECTOR(31 downto 0);
    signal alu_result : STD_LOGIC_VECTOR(31 downto 0);
    signal alu_zero : STD_LOGIC;
    signal branch_taken : STD_LOGIC;

    -- Función auxiliar para construir instrucción tipo B
    function make_b_type(
        imm12   : std_logic;  -- bit 12
        imm10_5 : std_logic_vector(5 downto 0);  -- bits 10:5
        rs2     : std_logic_vector(4 downto 0);
        rs1     : std_logic_vector(4 downto 0);
        func3   : std_logic_vector(2 downto 0);
        imm4_1  : std_logic_vector(3 downto 0);  -- bits 4:1
        imm11   : std_logic;  -- bit 11
        opcode  : std_logic_vector(6 downto 0)
    ) return std_logic_vector is
    begin
        return imm12 & imm10_5 & rs2 & rs1 & func3 & imm4_1 & imm11 & opcode;
    end function;

begin
    -- Instanciación del Decoder
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

    -- Instanciación de la ALU
    u_alu: ALU
        port map (
            do1       => rs1_data,
            do2       => rs2_data,
            op        => alu_op,
            resultado => alu_result,
            zero      => alu_zero
        );

    -- El branch se toma si el resultado de la comparación es verdadero (bit 0 = 1)
    branch_taken <= alu_result(0);

    -- Proceso de prueba
    stim_proc: process
    begin
        wait for 10 ns;
        
        report "=== TESTBENCH DE INSTRUCCIONES BRANCH ===";
        
        -- ====== Test 1: BEQ (Branch if Equal) ======
        report "Test 1: BEQ con rs1 = rs2 = 10 (debe tomar el branch)";
        rs1_data <= std_logic_vector(to_signed(10, 32));
        rs2_data <= std_logic_vector(to_signed(10, 32));
        -- BEQ x1, x2, 8
        instruction <= make_b_type(
            imm12   => '0',
            imm10_5 => "000000",
            rs2     => "00010",  -- x2
            rs1     => "00001",  -- x1
            func3   => "000",    -- BEQ
            imm4_1  => "0100",   -- offset = 8
            imm11   => '0',
            opcode  => "1100011" -- tipo B
        );
        wait for 10 ns;
        assert branch_taken = '1' report "ERROR: BEQ debería tomar el branch" severity error;
        assert reg_we = '0' report "ERROR: BEQ no debe escribir en registro" severity error;
        assert mem_we = '0' report "ERROR: BEQ no debe escribir en memoria" severity error;
        assert imm_src = "10" report "ERROR: BEQ debe usar formato tipo B" severity error;
        
        -- ====== Test 2: BEQ (no tomar branch) ======
        report "Test 2: BEQ con rs1 = 10, rs2 = 20 (NO debe tomar el branch)";
        rs1_data <= std_logic_vector(to_signed(10, 32));
        rs2_data <= std_logic_vector(to_signed(20, 32));
        wait for 10 ns;
        assert branch_taken = '0' report "ERROR: BEQ NO debería tomar el branch" severity error;
        
        -- ====== Test 3: BNE (Branch if Not Equal) ======
        report "Test 3: BNE con rs1 = 10, rs2 = 20 (debe tomar el branch)";
        rs1_data <= std_logic_vector(to_signed(10, 32));
        rs2_data <= std_logic_vector(to_signed(20, 32));
        -- BNE x1, x2, 12
        instruction <= make_b_type(
            imm12   => '0',
            imm10_5 => "000000",
            rs2     => "00010",  -- x2
            rs1     => "00001",  -- x1
            func3   => "001",    -- BNE
            imm4_1  => "0110",   -- offset = 12
            imm11   => '0',
            opcode  => "1100011" -- tipo B
        );
        wait for 10 ns;
        assert branch_taken = '1' report "ERROR: BNE debería tomar el branch" severity error;
        
        -- ====== Test 4: BLT (Branch if Less Than, signed) ======
        report "Test 4: BLT con rs1 = -5, rs2 = 10 (debe tomar el branch)";
        rs1_data <= std_logic_vector(to_signed(-5, 32));
        rs2_data <= std_logic_vector(to_signed(10, 32));
        -- BLT x3, x4, 16
        instruction <= make_b_type(
            imm12   => '0',
            imm10_5 => "000000",
            rs2     => "00100",  -- x4
            rs1     => "00011",  -- x3
            func3   => "100",    -- BLT
            imm4_1  => "1000",   -- offset = 16
            imm11   => '0',
            opcode  => "1100011" -- tipo B
        );
        wait for 10 ns;
        assert branch_taken = '1' report "ERROR: BLT debería tomar el branch (-5 < 10)" severity error;
        
        -- ====== Test 5: BLT (no tomar branch) ======
        report "Test 5: BLT con rs1 = 10, rs2 = -5 (NO debe tomar el branch)";
        rs1_data <= std_logic_vector(to_signed(10, 32));
        rs2_data <= std_logic_vector(to_signed(-5, 32));
        wait for 10 ns;
        assert branch_taken = '0' report "ERROR: BLT NO debería tomar el branch (10 >= -5)" severity error;
        
        -- ====== Test 6: BGE (Branch if Greater or Equal, signed) ======
        report "Test 6: BGE con rs1 = 10, rs2 = 10 (debe tomar el branch)";
        rs1_data <= std_logic_vector(to_signed(10, 32));
        rs2_data <= std_logic_vector(to_signed(10, 32));
        -- BGE x5, x6, 20
        instruction <= make_b_type(
            imm12   => '0',
            imm10_5 => "000000",
            rs2     => "00110",  -- x6
            rs1     => "00101",  -- x5
            func3   => "101",    -- BGE
            imm4_1  => "1010",   -- offset = 20
            imm11   => '0',
            opcode  => "1100011" -- tipo B
        );
        wait for 10 ns;
        assert branch_taken = '1' report "ERROR: BGE debería tomar el branch (10 >= 10)" severity error;
        
        -- ====== Test 7: BGE con valores diferentes ======
        report "Test 7: BGE con rs1 = 20, rs2 = 10 (debe tomar el branch)";
        rs1_data <= std_logic_vector(to_signed(20, 32));
        rs2_data <= std_logic_vector(to_signed(10, 32));
        wait for 10 ns;
        assert branch_taken = '1' report "ERROR: BGE debería tomar el branch (20 >= 10)" severity error;
        
        -- ====== Test 8: BLTU (Branch if Less Than, unsigned) ======
        report "Test 8: BLTU con rs1 = 5, rs2 = 10 (debe tomar el branch)";
        rs1_data <= std_logic_vector(to_unsigned(5, 32));
        rs2_data <= std_logic_vector(to_unsigned(10, 32));
        -- BLTU x7, x8, 24
        instruction <= make_b_type(
            imm12   => '0',
            imm10_5 => "000000",
            rs2     => "01000",  -- x8
            rs1     => "00111",  -- x7
            func3   => "110",    -- BLTU
            imm4_1  => "1100",   -- offset = 24
            imm11   => '0',
            opcode  => "1100011" -- tipo B
        );
        wait for 10 ns;
        assert branch_taken = '1' report "ERROR: BLTU debería tomar el branch (5 < 10 unsigned)" severity error;
        
        -- ====== Test 9: BGEU (Branch if Greater or Equal, unsigned) ======
        report "Test 9: BGEU con rs1 = 10, rs2 = 5 (debe tomar el branch)";
        rs1_data <= std_logic_vector(to_unsigned(10, 32));
        rs2_data <= std_logic_vector(to_unsigned(5, 32));
        -- BGEU x9, x10, 28
        instruction <= make_b_type(
            imm12   => '0',
            imm10_5 => "000000",
            rs2     => "01010",  -- x10
            rs1     => "01001",  -- x9
            func3   => "111",    -- BGEU
            imm4_1  => "1110",   -- offset = 28
            imm11   => '0',
            opcode  => "1100011" -- tipo B
        );
        wait for 10 ns;
        assert branch_taken = '1' report "ERROR: BGEU debería tomar el branch (10 >= 5 unsigned)" severity error;
        
        -- ====== Test 10: BGEU con valores iguales ======
        report "Test 10: BGEU con rs1 = rs2 = 15 (debe tomar el branch)";
        rs1_data <= std_logic_vector(to_unsigned(15, 32));
        rs2_data <= std_logic_vector(to_unsigned(15, 32));
        wait for 10 ns;
        assert branch_taken = '1' report "ERROR: BGEU debería tomar el branch (15 >= 15 unsigned)" severity error;
        
        -- ====== Test 11: Inmediato negativo con BEQ ======
        report "Test 11: BEQ con offset negativo (branch hacia atrás)";
        rs1_data <= std_logic_vector(to_signed(100, 32));
        rs2_data <= std_logic_vector(to_signed(100, 32));
        -- BEQ x11, x12, -8 (offset negativo)
        instruction <= make_b_type(
            imm12   => '1',       -- bit de signo
            imm10_5 => "111111",  -- offset negativo
            rs2     => "01100",   -- x12
            rs1     => "01011",   -- x11
            func3   => "000",     -- BEQ
            imm4_1  => "1100",    
            imm11   => '1',
            opcode  => "1100011"  -- tipo B
        );
        wait for 10 ns;
        assert branch_taken = '1' report "ERROR: BEQ con offset negativo debería tomar el branch" severity error;
        
        wait for 20 ns;
        report "=== TODOS LOS TESTS DE BRANCH COMPLETADOS EXITOSAMENTE ===";
        wait;
    end process;

end testbench;
