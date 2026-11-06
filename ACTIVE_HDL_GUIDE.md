# Guía para Crear el Esquema en Active-HDL

## Archivo Top-Level Creado

Se ha creado `riscv_processor_top.vhdl` que es el módulo principal del procesador, completamente estructural y listo para usar en Active-HDL.

## Pasos para Usar en Active-HDL

### 1. Crear un Nuevo Proyecto en Active-HDL

1. Abre Active-HDL
2. **File → New → Design**
3. Nombre del proyecto: `RISC_V_Processor`
4. Selecciona VHDL como lenguaje
5. Selecciona la familia de FPGA (o usa la biblioteca de simulación)

### 2. Agregar los Archivos al Proyecto

Agrega todos los archivos en este orden:

**Módulos Core (src/core/):**
```
1. alu.vhdl
2. decoder.vhdl
3. imm_extend.vhdl
4. register_file.vhdl
5. data_memory.vhdl
6. program_counter.vhdl
7. instruction_memory_fibonacci.vhdl
8. riscv_processor_top.vhdl  ← Módulo Top-Level
```

**Click derecho en el proyecto → Add Files to Design → Seleccionar todos los archivos**

### 3. Compilar el Diseño

1. **Design → Compile → Compile All**
2. Verifica que todos los archivos se compilen sin errores
3. El orden de compilación es importante (Active-HDL normalmente lo maneja automáticamente)

### 4. Crear el Esquema Visual (Block Diagram)

#### Opción A: Generar desde VHDL
1. Click derecho en `riscv_processor_top` → **Generate Block Diagram**
2. Active-HDL creará automáticamente un diagrama de bloques mostrando:
   - Todos los componentes instanciados
   - Las interconexiones entre componentes
   - Los puertos de entrada/salida

#### Opción B: Crear Manualmente
1. **File → New → Block Diagram**
2. Arrastra los componentes desde la biblioteca
3. Conecta las señales manualmente

### 5. Crear un Testbench para Simulación

Puedes usar el testbench existente o crear uno simple:

**En Active-HDL:**
1. **File → New → VHDL File**
2. Nombre: `tb_riscv_processor.vhd`
3. Usa este código simple:

```vhdl
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_riscv_processor is
end tb_riscv_processor;

architecture behavior of tb_riscv_processor is
    signal clk : STD_LOGIC := '0';
    signal reset : STD_LOGIC := '1';
    signal pc_out : STD_LOGIC_VECTOR(31 downto 0);
    signal instr_out : STD_LOGIC_VECTOR(31 downto 0);
    signal alu_res_out : STD_LOGIC_VECTOR(31 downto 0);
    signal reg_we_out : STD_LOGIC;
    signal mem_we_out : STD_LOGIC;
    signal branch_out : STD_LOGIC;
    
    constant CLK_PERIOD : time := 10 ns;
begin
    UUT: entity work.riscv_processor_top
        port map (
            clk => clk,
            reset => reset,
            pc_out => pc_out,
            instr_out => instr_out,
            alu_res_out => alu_res_out,
            reg_we_out => reg_we_out,
            mem_we_out => mem_we_out,
            branch_out => branch_out
        );
    
    -- Clock
    clk <= not clk after CLK_PERIOD/2;
    
    -- Reset
    process
    begin
        reset <= '1';
        wait for 20 ns;
        reset <= '0';
        wait;
    end process;
end behavior;
```

### 6. Ejecutar la Simulación

1. Click derecho en el testbench → **Set as Top-Level**
2. **Simulation → Initialize Simulation**
3. Agrega señales al visor de formas de onda:
   - `clk`
   - `reset`
   - `pc_out`
   - `instr_out`
   - `alu_res_out`
   - `reg_we_out`
   - `mem_we_out`
   - `branch_out`
4. **Simulation → Run → Run for 1500 ns**

### 7. Visualizar el Esquema

1. **View → Block Diagram Viewer**
2. Verás el procesador completo con todos sus componentes:

```
┌────────────────────────────────────────────────┐
│        riscv_processor_top                     │
│                                                 │
│  clk ──────┬──────────────────────────┐        │
│  reset ────┼──────────┐               │        │
│            │          │               │        │
│      ┌─────▼────┐     │               │        │
│      │    PC    │     │               │        │
│      └─────┬────┘     │               │        │
│            │          │               │        │
│            ▼          │               │        │
│      ┌─────────┐      │               │        │
│      │  IMEM   │      │               │        │
│      └────┬────┘      │               │        │
│           │           │               │        │
│           ▼           ▼               │        │
│      ┌──────────┐ ┌─────────┐        │        │
│      │ DECODER  │ │ REGFILE │        │        │
│      └────┬─────┘ └────┬────┘        │        │
│           │            │             │        │
│           ▼            ▼             ▼        │
│      ┌─────────────────────────────────┐     │
│      │            ALU                   │     │
│      └─────────────┬────────────────────┘     │
│                    │                          │
│                    ▼                          │
│              ┌──────────┐                     │
│              │   DMEM   │                     │
│              └──────────┘                     │
│                                                │
└────────────────────────────────────────────────┘
```

## Señales de Interés para Debugging

**Program Counter & Instruction:**
- `pc_current` - PC actual
- `instruction` - Instrucción que se ejecuta
- `pc_next` - Próximo PC

**Control Signals:**
- `ctrl_reg_we` - Write enable registros
- `ctrl_mem_we` - Write enable memoria
- `ctrl_alu_src` - Fuente operando 2 ALU
- `ctrl_alu_op` - Operación ALU

**Datapath:**
- `reg_rs1_data` - Valor de rs1
- `reg_rs2_data` - Valor de rs2
- `alu_result` - Resultado ALU
- `imm_extended` - Inmediato extendido

**Branch:**
- `branch_taken` - Se tomó el branch
- `pc_branch` - Dirección de branch

## Características del Módulo Top-Level

✅ **Completamente Estructural** - Solo instancias de componentes
✅ **Sin Lógica Algorítmica** - Todo es hardware real
✅ **Puertos de Monitoreo** - Señales clave expuestas para debugging
✅ **Listo para Síntesis** - Puede sintetizarse en FPGA
✅ **Compatible con Active-HDL** - Sigue convenciones de diseño esquemático

## Verificación de Funcionamiento

El procesador ejecuta el programa de Fibonacci:
1. Inicializa variables
2. Guarda fib(0)=0 y fib(1)=1 en memoria
3. Entra en loop para calcular fib(2) a fib(9)
4. Cada valor se guarda en memoria
5. Sale del loop cuando contador >= 10

**Resultado esperado en memoria:**
```
Addr 0x00: 0
Addr 0x04: 1
Addr 0x08: 1
Addr 0x0C: 2
Addr 0x10: 3
Addr 0x14: 5
Addr 0x18: 8
Addr 0x1C: 13
Addr 0x20: 21
Addr 0x24: 34
```

## Exportar el Esquema

En Active-HDL puedes:
1. **File → Export → Block Diagram → PDF/PNG**
2. Exportar el netlist completo
3. Generar reporte de síntesis

## Notas Importantes

- El módulo usa `instruction_memory_fibonacci` que tiene el programa precargado
- Si quieres cambiar el programa, modifica ese archivo
- El procesador es completamente funcional y sintetizable
- Todos los componentes están probados y funcionando
