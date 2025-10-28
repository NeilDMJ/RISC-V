# RISC-V Processor Implementation in VHDL

Implementación educativa de un procesador RISC-V de 32 bits en VHDL, desarrollado como parte del curso de Arquitectura de Computadoras.

## Características

- Soporte para instrucciones **Tipo R** (operaciones registro-registro)
- Soporte para instrucciones **Tipo I** (operaciones con inmediatos)
- ALU de 32 bits con 9 operaciones
- Banco de registros de 32 registros × 32 bits
- Decodificador de instrucciones
- Extensor de inmediatos con signo
- Memoria de datos

## Componentes Implementados

### 1. ALU (Unidad Aritmético-Lógica)
Operaciones soportadas:
- `0000`: ADD (suma)
- `0001`: SUB (resta)
- `0010`: SLL (desplazamiento lógico izquierda)
- `0100`: SLT (set less than, con signo)
- `0110`: SLTU (set less than, sin signo)
- `1000`: XOR (or exclusivo)
- `1010`: SRL (desplazamiento lógico derecha)
- `1011`: SRA (desplazamiento aritmético derecha)
- `1100`: OR (or lógico)
- `1110`: AND (and lógico)

### 2. Decoder (Decodificador)
- Recibe instrucciones de 32 bits
- Extrae campos: opcode, func3, func7
- Genera señales de control:
  - `we`: Write Enable para banco de registros
  - `alu_src`: Selector de fuente (registro/inmediato)
  - `op`: Código de operación para ALU

### 3. Banco de Registros
- 32 registros de 32 bits
- 2 puertos de lectura
- 1 puerto de escritura
- x0 siempre es 0 (hardwired)

### 4. Extensor de Inmediatos
- Extiende inmediatos de 12 bits a 32 bits
- Extensión de signo para números negativos
- Soporte para formato tipo I

## Instrucciones Soportadas

### Tipo R (Registro-Registro)
| Instrucción | Opcode    | func3 | func7   | Operación       |
|-------------|-----------|-------|---------|-----------------|
| ADD         | 0110011   | 000   | 0000000 | rd = rs1 + rs2  |
| SUB         | 0110011   | 000   | 0100000 | rd = rs1 - rs2  |
| SLL         | 0110011   | 001   | 0000000 | rd = rs1 << rs2 |
| SLT         | 0110011   | 010   | 0000000 | rd = rs1 < rs2  |
| SLTU        | 0110011   | 011   | 0000000 | rd = rs1 < rs2 (unsigned) |
| XOR         | 0110011   | 100   | 0000000 | rd = rs1 ^ rs2  |
| SRL         | 0110011   | 101   | 0000000 | rd = rs1 >> rs2 |
| SRA         | 0110011   | 101   | 0100000 | rd = rs1 >> rs2 (arit) |
| OR          | 0110011   | 110   | 0000000 | rd = rs1 \| rs2 |
| AND         | 0110011   | 111   | 0000000 | rd = rs1 & rs2  |

### Tipo I (Registro-Inmediato)
| Instrucción | Opcode    | func3 | Operación          |
|-------------|-----------|-------|--------------------|
| ADDI        | 0010011   | 000   | rd = rs1 + imm     |
| SLLI        | 0010011   | 001   | rd = rs1 << imm    |
| SLTI        | 0010011   | 010   | rd = rs1 < imm     |
| SLTIU       | 0010011   | 011   | rd = rs1 < imm (unsigned) |
| XORI        | 0010011   | 100   | rd = rs1 ^ imm     |
| SRLI        | 0010011   | 101   | rd = rs1 >> imm    |
| SRAI        | 0010011   | 101   | rd = rs1 >> imm (arit) |
| ORI         | 0010011   | 110   | rd = rs1 \| imm    |
| ANDI        | 0010011   | 111   | rd = rs1 & imm     |

## Cómo Usar

### Requisitos
- GHDL (compilador/simulador VHDL)
- GTKWave (visor de formas de onda)

### Instalación en Linux
```bash
sudo apt-get install ghdl gtkwave
```

### Compilar y Simular

#### Simulación de instrucciones Tipo I
```bash
cd scripts
chmod +x simular_typei.sh
./simular_typei.sh
```

#### Compilación manual
```bash
cd src/core
ghdl -a --std=08 ALU.vhdl
ghdl -a --std=08 Decoder.vhdl
ghdl -a --std=08 ImmExtend.vhdl
ghdl -a --std=08 BancoDeRegistros.vhdl

cd ../testbenches
ghdl -a --std=08 tb_TypeI.vhdl
ghdl -e --std=08 tb_TypeI
ghdl -r --std=08 tb_TypeI --vcd=../../sim/wave_typei.vcd
```

#### Visualizar formas de onda
```bash
gtkwave sim/wave_typei.vcd
```

## Señales Importantes en GTKWave

- `instr`: Instrucción completa de 32 bits
- `alu_src`: Señal de control (0=registro, 1=inmediato)
- `we`: Write Enable
- `op`: Código de operación para ALU
- `do1`: Primer operando (rs1)
- `imm_ext`: Inmediato extendido
- `do2_alu`: Segundo operando seleccionado
- `resultado`: Resultado de la ALU

## Tests Incluidos

### `typei_tb.vhdl`
- 12 pruebas de instrucciones tipo I
- 2 pruebas de instrucciones tipo R para comparación
- Cobertura de todas las operaciones soportadas
- Pruebas con números positivos y negativos

### `alu_decoder_tb.vhdl`
- Pruebas individuales de ALU y Decoder
- 10 operaciones tipo R

### `register_file_tb.vhdl`
- Pruebas de lectura y escritura de registros
- Verificación de x0 = 0

## Proyecto Académico

Este proyecto fue desarrollado como parte del curso de **Arquitectura de Computadoras** en la Universidad Tecnologica de la Mixteca.

### Objetivos de Aprendizaje
- Comprender la arquitectura RISC-V
- Diseñar componentes digitales en VHDL
- Implementar datapath y control de un procesador
- Realizar simulaciones y verificación

## Próximas Características

- [ ] Instrucciones Tipo S (Store)
- [ ] Instrucciones Tipo B (Branch)
- [ ] Instrucciones Tipo U (Upper immediate)
- [ ] Instrucciones Tipo J (Jump)
- [ ] Control de hazards
- [ ] Pipeline

## Autor



## Licencia

Este proyecto es de código abierto y está disponible para fines educativos.

---

**Nota**: Este es un procesador educativo y no está optimizado para síntesis en FPGA.
