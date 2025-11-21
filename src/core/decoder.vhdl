library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity decoder is
    port (
        instr       : in STD_LOGIC_VECTOR(31 downto 0);  --instruccion completa de 32 bits
        reg_we      : out STD_LOGIC;                      --write enable para banco de registros
        mem_we      : out STD_LOGIC;                      --write enable para memoria de datos
        alu_src     : out STD_LOGIC;                      --selector de fuente para ALU (0=registro, 1=inmediato)
        mem_to_reg  : out STD_LOGIC;                      --selector de dato a escribir en registro (0=ALU, 1=memoria)
        imm_src     : out STD_LOGIC_VECTOR(1 downto 0);   --selector de formato de inmediato (00=I, 01=S, 10=B)
        op          : out STD_LOGIC_VECTOR(3 downto 0)    --operacion a realizar en la ALU
    );
end decoder;

architecture behavioral of decoder is --señales internas
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
        --valores por defecto
        reg_we <= '0';      --no escribir en registros
        mem_we <= '0';      --no escribir en memoria
        alu_src <= '0';     --usar registro
        mem_to_reg <= '0';  --dato viene de la ALU
        imm_src <= "00";    --formato tipo I
        op <= "1111";       --operacion no definida
        
        case opcode is 
            when "0110011" => --implementar tipo R (opcode no cambia)
                reg_we <= '1'; --activar la escritura en el banco de registros
                mem_we <= '0'; --no escribir en memoria
                alu_src <= '0'; --usar registro (rs2)
                mem_to_reg <= '0'; --escribir resultado de ALU en registro
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
                reg_we <= '1'; --activar la escritura en el banco de registros
                mem_we <= '0'; --no escribir en memoria
                alu_src <= '1'; --usar inmediato en lugar de registro
                mem_to_reg <= '0'; --escribir resultado de ALU en registro
                imm_src <= "00"; --formato tipo I
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
            when "0000011" => --implementar tipo L (instrucciones de carga/load)
                reg_we <= '1'; --activar la escritura en el banco de registros (se escribe el dato leido de memoria)
                mem_we <= '0'; --no escribir en memoria (solo leer)
                alu_src <= '1'; --usar inmediato para calcular la direccion de memoria
                mem_to_reg <= '1'; --escribir dato de memoria en registro
                imm_src <= "00"; --formato tipo I
                case func3 is 
                    when "000" => --LB (load byte con extension de signo)
                        op <= "0000"; --suma (rs1 + inmediato para calcular direccion)
                    when "001" => --LH (load halfword con extension de signo)
                        op <= "0000"; --suma
                    when "010" => --LW (load word)
                        op <= "0000"; --suma
                    when "100" => --LBU (load byte sin extension de signo)
                        op <= "0000"; --suma
                    when "101" => --LHU (load halfword sin extension de signo)
                        op <= "0000"; --suma
                    when others =>
                        op <= "1111"; --operacion no definida
                end case;
            when "0100011" => --implementar tipo S (instrucciones de almacenamiento/store)
                reg_we <= '0'; --NO escribir en el banco de registros (solo se escribe en memoria)
                mem_we <= '1'; --activar escritura en memoria
                alu_src <= '1'; --usar inmediato para calcular la direccion de memoria
                mem_to_reg <= '0'; --no importa (no se escribe en registro)
                imm_src <= "01"; --formato tipo S
                case func3 is 
                    when "000" => --SB (store byte)
                        op <= "0000"; --suma (rs1 + inmediato para calcular direccion)
                    when "001" => --SH (store halfword)
                        op <= "0000"; --suma
                    when "010" => --SW (store word)
                        op <= "0000"; --suma
                    when others =>
                        op <= "1111"; --operacion no definida
                end case;
            when "1100011" => --implementar tipo B (instrucciones de salto condicional/branch)
                reg_we <= '0'; --NO escribir en el banco de registros
                mem_we <= '0'; --NO escribir en memoria
                alu_src <= '0'; --usar registro rs2 (comparar rs1 con rs2)
                mem_to_reg <= '0'; --no importa (no se escribe en registro)
                imm_src <= "10"; --formato tipo B
                case func3 is 
                    when "000" => --BEQ (branch if equal)
                        op <= "1100"; --comparacion de igualdad
                    when "001" => --BNE (branch if not equal)
                        op <= "1101"; --comparacion de desigualdad
                    when "100" => --BLT (branch if less than, signed)
                        op <= "1000"; --SLT (reutilizar hardware de comparacion)
                    when "101" => --BGE (branch if greater or equal, signed)
                        op <= "1010"; --SGE (comparacion mayor o igual)
                    when "110" => --BLTU (branch if less than, unsigned)
                        op <= "1001"; --SLTU (reutilizar hardware de comparacion unsigned)
                    when "111" => --BGEU (branch if greater or equal, unsigned)
                        op <= "1011"; --SGEU (comparacion mayor o igual unsigned)
                    when others =>
                        op <= "1111"; --operacion no definida
                end case;
            when others =>
                reg_we <= '0';
                mem_we <= '0';
                op <= "1111";
        end case;              
                        
    end process;

end behavioral;