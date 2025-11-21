library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity decoder is
    port (
        instr       : in  STD_LOGIC_VECTOR(31 downto 0);  -- instruccion completa de 32 bits
        reg_we      : out STD_LOGIC;                      -- write enable para banco de registros
        mem_we      : out STD_LOGIC;                      -- write enable para memoria de datos
        alu_src     : out STD_LOGIC;                      -- selector de fuente para ALU (0=registro, 1=inmediato)
        mem_to_reg  : out STD_LOGIC;                      -- selector de dato a escribir en registro (0=ALU, 1=memoria)
        imm_src     : out STD_LOGIC;                      -- selector de formato de inmediato (0=tipo I, 1=tipo S)
        op          : out STD_LOGIC_VECTOR(3 downto 0);   -- operacion a realizar en la ALU

        -- *** Nuevos puertos para branch (según el diagrama y la lógica de PC) ***
        branch      : out STD_LOGIC;                      -- '1' si la instruccion es de tipo branch
        branch_type : out STD_LOGIC_VECTOR(1 downto 0)    -- 00=beq, 01=blt, 10=bltu
    );
end decoder;

architecture behavioral of decoder is -- señales internas
    signal opcode : std_logic_vector(6 downto 0);
    signal func3  : std_logic_vector(2 downto 0);
    signal func7  : std_logic_vector(6 downto 0);
begin
    -- separacion de campos segun el formato RISC-V
    opcode <= instr(6 downto 0);    -- bits [6:0]
    func3  <= instr(14 downto 12);  -- bits [14:12]
    func7  <= instr(31 downto 25);  -- bits [31:25]

    process(opcode, func3, func7)
    begin
        -- valores por defecto (NINGUN branch, operacion "no definida")
        reg_we      <= '0';      -- no escribir en registros
        mem_we      <= '0';      -- no escribir en memoria
        alu_src     <= '0';      -- usar registro
        mem_to_reg  <= '0';      -- dato viene de la ALU
        imm_src     <= '0';      -- formato tipo I
        op          <= "1111";   -- operacion no definida

        -- Nuevos: por defecto no hay branch
        branch      <= '0';
        branch_type <= "00";

        case opcode is
            ----------------------------------------------------------------
            -- Tipo R
            ----------------------------------------------------------------
            when "0110011" =>
                reg_we     <= '1';  -- activar la escritura en el banco de registros
                mem_we     <= '0';
                alu_src    <= '0';  -- usar registro (rs2)
                mem_to_reg <= '0';  -- escribir resultado de ALU en registro

                case func3 is
                    when "000" => -- suma / resta
                        case func7 is
                            when "0000000" =>
                                op <= "0000"; -- suma
                            when "0100000" =>
                                op <= "0001"; -- resta
                            when others    =>
                                op <= "1111";
                        end case;
                    when "001" => -- sll
                        op <= "0010";
                    when "010" => -- slt
                        op <= "0100";
                    when "011" => -- sltu
                        op <= "0110";
                    when "100" => -- xor
                        op <= "1000";
                    when "101" => -- srl / sra
                        case func7 is
                            when "0000000" =>
                                op <= "1010"; -- srl
                            when "0100000" =>
                                op <= "1011"; -- sra
                            when others    =>
                                op <= "1111";
                        end case;
                    when "110" => -- or
                        op <= "1100";
                    when "111" => -- and
                        op <= "1110";
                    when others =>
                        op <= "1111";
                end case;

            ----------------------------------------------------------------
            -- Tipo I aritmetico
            ----------------------------------------------------------------
            when "0010011" =>
                reg_we     <= '1';
                mem_we     <= '0';
                alu_src    <= '1';  -- usar inmediato
                mem_to_reg <= '0';
                imm_src    <= '0';  -- formato tipo I

                case func3 is
                    when "000" => -- ADDI
                        op <= "0000";
                    when "001" => -- SLLI
                        op <= "0010";
                    when "010" => -- SLTI
                        op <= "0100";
                    when "011" => -- SLTIU
                        op <= "0110";
                    when "100" => -- XORI
                        op <= "1000";
                    when "101" => -- SRLI / SRAI
                        case func7 is
                            when "0000000" =>
                                op <= "1010"; -- SRLI
                            when "0100000" =>
                                op <= "1011"; -- SRAI
                            when others    =>
                                op <= "1111";
                        end case;
                    when "110" => -- ORI
                        op <= "1100";
                    when "111" => -- ANDI
                        op <= "1110";
                    when others =>
                        op <= "1111";
                end case;

            ----------------------------------------------------------------
            -- Tipo L (cargas)
            ----------------------------------------------------------------
            when "0000011" =>
                reg_we     <= '1';  -- escribir dato leido en registro
                mem_we     <= '0';  -- solo lectura de memoria
                alu_src    <= '1';  -- rs1 + inmediato
                mem_to_reg <= '1';  -- dato viene de memoria
                imm_src    <= '0';  -- formato I

                case func3 is
                    when "000" => -- LB
                        op <= "0000"; -- suma para direccion
                    when "001" => -- LH
                        op <= "0000";
                    when "010" => -- LW
                        op <= "0000";
                    when "100" => -- LBU
                        op <= "0000";
                    when "101" => -- LHU
                        op <= "0000";
                    when others =>
                        op <= "1111";
                end case;

            ----------------------------------------------------------------
            -- Tipo S (stores)
            ----------------------------------------------------------------
            when "0100011" =>
                reg_we     <= '0';  -- no escribir en banco de registros
                mem_we     <= '1';  -- escribir en memoria
                alu_src    <= '1';  -- rs1 + inmediato
                mem_to_reg <= '0';
                imm_src    <= '1';  -- formato S

                case func3 is
                    when "000" => -- SB
                        op <= "0000";
                    when "001" => -- SH
                        op <= "0000";
                    when "010" => -- SW
                        op <= "0000";
                    when others =>
                        op <= "1111";
                end case;

            ----------------------------------------------------------------
            -- Tipo B (branches)  *** NUEVO ***
            -- opcode = 1100011
            ----------------------------------------------------------------
            when "1100011" =>
                reg_we     <= '0';  -- no escribir registros
                mem_we     <= '0';  -- no escribir memoria
                alu_src    <= '0';  -- comparar registros rs1 y rs2
                mem_to_reg <= '0';
                imm_src    <= '0';  -- no se usa para branch en este diseño
                op         <= "0001"; -- Suposición necesaria: usar SUB (rs1 - rs2)
                                      -- si se quisieran usar flags de cero desde la ALU.
                branch     <= '1';    -- habilitar lógica de branch

                -- Selección del tipo de branch según func3 (estándar RISC-V)
                -- func3 = 000 -> BEQ
                -- func3 = 100 -> BLT
                -- func3 = 110 -> BLTU
                case func3 is
                    when "000" =>       -- BEQ
                        branch_type <= "00";
                    when "100" =>       -- BLT (signed)
                        branch_type <= "01";
                    when "110" =>       -- BLTU (unsigned)
                        branch_type <= "10";
                    when others =>
                        branch_type <= "00"; -- por seguridad, no se toma el branch
                end case;

            ----------------------------------------------------------------
            -- Otros opcodes no soportados
            ----------------------------------------------------------------
            when others =>
                reg_we      <= '0';
                mem_we      <= '0';
                alu_src     <= '0';
                mem_to_reg  <= '0';
                imm_src     <= '0';
                op          <= "1111";
                branch      <= '0';
                branch_type <= "00";
        end case;

    end process;

end behavioral;