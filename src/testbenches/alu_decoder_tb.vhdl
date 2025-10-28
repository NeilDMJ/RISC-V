library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_ALU_Decoder is
end tb_ALU_Decoder;

architecture Behavioral of tb_ALU_Decoder is
    -- Componente Decoder
    component Decoder is
        port (
            instr_code  : in STD_LOGIC_VECTOR(16 downto 0);
            we          : out STD_LOGIC;
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

    -- Señales de prueba
    signal instr_code : STD_LOGIC_VECTOR(16 downto 0) := (others => '0');
    signal we         : STD_LOGIC;
    signal op         : STD_LOGIC_VECTOR(3 downto 0);
    signal do1        : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal do2        : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal resultado  : STD_LOGIC_VECTOR(31 downto 0);

    -- Función auxiliar para construir instrucción
    function make_instruction(opcode: std_logic_vector(6 downto 0);
                             func3: std_logic_vector(2 downto 0);
                             func7: std_logic_vector(6 downto 0))
                             return std_logic_vector is
    begin
        return func7 & func3 & opcode;
    end function;

begin
    -- Instanciación del Decoder
    UUT_Decoder: Decoder
        port map (
            instr_code => instr_code,
            we         => we,
            op         => op
        );

    -- Instanciación de la ALU
    UUT_ALU: ALU
        port map (
            do1       => do1,
            do2       => do2,
            op        => op,
            resultado => resultado
        );

    -- Proceso de estímulos
    stimulus: process
    begin
        -- Valores iniciales
        do1 <= std_logic_vector(to_signed(15, 32));
        do2 <= std_logic_vector(to_signed(10, 32));
        wait for 10 ns;

        -- Test 1: ADD
        instr_code <= make_instruction("0110011", "000", "0000000");
        wait for 10 ns;

        -- Test 2: SUB
        instr_code <= make_instruction("0110011", "000", "0100000");
        wait for 10 ns;

        -- Test 3: SLL
        do1 <= std_logic_vector(to_signed(15, 32));
        do2 <= std_logic_vector(to_signed(2, 32));
        instr_code <= make_instruction("0110011", "001", "0000000");
        wait for 10 ns;

        -- Test 4: SLT
        do1 <= std_logic_vector(to_signed(10, 32));
        do2 <= std_logic_vector(to_signed(15, 32));
        instr_code <= make_instruction("0110011", "010", "0000000");
        wait for 10 ns;

        -- Test 5: SLTU
        do1 <= std_logic_vector(to_unsigned(10, 32));
        do2 <= std_logic_vector(to_unsigned(15, 32));
        instr_code <= make_instruction("0110011", "011", "0000000");
        wait for 10 ns;

        -- Test 6: XOR
        do1 <= std_logic_vector(to_signed(15, 32));
        do2 <= std_logic_vector(to_signed(10, 32));
        instr_code <= make_instruction("0110011", "100", "0000000");
        wait for 10 ns;

        -- Test 7: SRL
        do1 <= std_logic_vector(to_signed(60, 32));
        do2 <= std_logic_vector(to_signed(2, 32));
        instr_code <= make_instruction("0110011", "101", "0000000");
        wait for 10 ns;

        -- Test 8: SRA
        do1 <= std_logic_vector(to_signed(-8, 32));
        do2 <= std_logic_vector(to_signed(1, 32));
        instr_code <= make_instruction("0110011", "101", "0100000");
        wait for 10 ns;

        -- Test 9: OR
        do1 <= std_logic_vector(to_signed(12, 32));
        do2 <= std_logic_vector(to_signed(10, 32));
        instr_code <= make_instruction("0110011", "110", "0000000");
        wait for 10 ns;

        -- Test 10: AND
        do1 <= std_logic_vector(to_signed(15, 32));
        do2 <= std_logic_vector(to_signed(10, 32));
        instr_code <= make_instruction("0110011", "111", "0000000");
        wait for 10 ns;

        -- Test 11: Instrucción inválida
        instr_code <= make_instruction("0010011", "000", "0000000");
        wait for 100 ns;

        wait;
    end process;

end Behavioral;