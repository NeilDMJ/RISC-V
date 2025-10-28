library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Decoder is
    port (
        instr       : in STD_LOGIC_VECTOR(31 downto 0); --instruccion completa de 32 bits
        we          : out STD_LOGIC;                     --write enable
        alu_src     : out STD_LOGIC;                     --selector de fuente para ALU (0=registro, 1=inmediato)
        op          : out STD_LOGIC_VECTOR(3 downto 0)   --operacion a realizar en la ALU
    );
end Decoder;

architecture Decoder of Decoder is --señales internas
    signal opcode : std_logic_vector(6 downto 0);
    signal func3  : std_logic_vector(2 downto 0);
    signal func7  : std_logic_vector(6 downto 0);
begin
--separacion de campos segun el formato RISC-V
    opcode <= instr(6 downto 0);    -- bits [6:0]
    func3  <= instr(14 downto 12);  -- bits [14:12]
    func7  <= instr(31 downto 25);  -- bits [31:25]

    process(opcode,func3,func7)
    begin
        we <= '0';
        alu_src <= '0'; --por defecto usar registro
        op <= "1111"; --operacion no definida
        case opcode is 
            when "0110011" => --implementar tipo R (opcode no cambia)
                we <= '1'; --activar la escritura en el banco de registros
                case func3 is 
                    when "000" => --casos para suma y resta 
                        case func7 is
                            when "0000000" =>
                                op <= "0000"; --suma
                            when "0100000" =>
                                op <= "0001"; --resta
                            when others =>  
                                op <= "1111"; --operacion no definida
                        end case;
                    when "001" => --caso para sll
                        op <= "0010";
                    when "010" => --caso para slt
                        op <= "0100";
                    when "011" => --caso para sltu
                        op <= "0110";
                    when "100" => --caso para xor
                        op <= "1000";
                    when "101" => --caso para srl y sra
                        case func7 is
                            when "0000000" =>
                                op <= "1010"; --srl
                            when "0100000" =>
                                op <= "1011"; --sra
                            when others =>  
                                op <= "1111"; --operacion no definida
                        end case;
                    when "110" => --caso para or
                        op <= "1100";
                    when "111" => --caso para and
                        op <= "1110";
                    when others =>
                        op <= "1111"; --operacion no definida
                end case;
            when "0010011" => --implementar tipo I (operaciones aritmeticas con inmediatos)
                we <= '1'; --activar la escritura en el banco de registros
                alu_src <= '1'; --usar inmediato en lugar de registro
                case func3 is 
                    when "000" => --ADDI (suma con inmediato)
                        op <= "0000"; --suma
                    when "001" => --SLLI (desplazamiento logico izquierda)
                        op <= "0010"; --sll
                    when "010" => --SLTI (set less than con inmediato)
                        op <= "0100"; --set less than
                    when "011" => --SLTIU (set less than unsigned con inmediato)
                        op <= "0110"; --set less than unsigned
                    when "100" => --XORI (xor con inmediato)
                        op <= "1000"; --xor
                    when "101" => --SRLI y SRAI (desplazamientos a la derecha)
                        case func7 is
                            when "0000000" =>
                                op <= "1010"; --srl
                            when "0100000" =>
                                op <= "1011"; --sra
                            when others =>  
                                op <= "1111"; --operacion no definida
                        end case;
                    when "110" => --ORI (or con inmediato)
                        op <= "1100"; --or
                    when "111" => --ANDI (and con inmediato)
                        op <= "1110"; --and
                    when others =>
                        op <= "1111"; --operacion no definida
                end case;
            when others =>
                we <= '0';
                op <= "1111";
        end case;              
                        
    end process;

end Decoder;