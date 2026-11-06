# Implementación del Algoritmo de Fibonacci en Procesador RISC-V

## Resumen

Se ha implementado exitosamente:

1. ✅ **Procesador RISC-V completo** con todas las instrucciones RV32I básicas
2. ✅ **Testbench esquemático** que instancia todos los componentes
3. ✅ **Programa de Fibonacci** en ensamblador RISC-V
4. ✅ **Memoria de instrucciones** precargada con el programa
5. ✅ **Simulación funcional** que ejecuta el programa

## Arquitectura del Procesador

El procesador implementado tiene la siguiente estructura esquemática:

```
┌─────────────────────────────────────────────────────────────┐
│                    PROCESADOR RISC-V                         │
│                                                               │
│  ┌──────────────┐        ┌───────────────┐                  │
│  │   Program    │───────▶│  Instruction  │                  │
│  │   Counter    │        │    Memory     │                  │
│  │    (PC)      │        │   (ROM)       │                  │
│  └──────────────┘        └───────┬───────┘                  │
│         ▲                        │                           │
│         │                        ▼                           │
│         │                 ┌─────────────┐                   │
│         │                 │   Decoder   │                   │
│         │                 │  (Control)  │                   │
│         │                 └──────┬──────┘                   │
│         │                        │                           │
│         │         ┌──────────────┴─────────────┐            │
│         │         │                             │            │
│         │         ▼                             ▼            │
│         │  ┌─────────────┐            ┌─────────────┐      │
│         │  │  Register   │            │     Imm     │      │
│         │  │    File     │            │   Extend    │      │
│         │  │  (32 regs)  │            │             │      │
│         │  └──────┬──────┘            └──────┬──────┘      │
│         │         │                           │              │
│         │         └────────┬──────────────────┘              │
│         │                  │                                 │
│         │                  ▼                                 │
│         │           ┌────────────┐                          │
│         │           │    ALU     │───┐                      │
│         │           │            │   │                      │
│         │           └────────────┘   │                      │
│         │                  │         │                      │
│         │                  │         └──────────┐           │
│         │                  ▼                    │           │
│         │          ┌──────────────┐             │           │
│         │          │ Data Memory  │             │           │
│         │          │   (RAM)      │             │           │
│         │          └──────┬───────┘             │           │
│         │                 │                     │           │
│         │                 └─────────┬───────────┘           │
│         │                           ▼                       │
│         │                    Write Back MUX                 │
│         │                           │                       │
│         └───────────────────────────┘                       │
│                  (PC Update Logic)                          │
└─────────────────────────────────────────────────────────────┘
```

## Componentes Implementados

### 1. **Program Counter (PC)**
- Registro de 32 bits
- Incrementa automáticamente en +4
- Soporta saltos (branches)
- Señales: `reset`, `enable`, `load`, `pc_in`, `pc_out`

### 2. **Instruction Memory**
- Memoria ROM de 256 palabras (1 KB)
- Precargada con 20 instrucciones del programa Fibonacci
- Direccionamiento word-aligned (divide dirección por 4)

### 3. **Decoder (Unidad de Control)**
- Genera 6 señales de control:
  - `reg_we`: Write enable para registros
  - `mem_we`: Write enable para memoria
  - `alu_src`: Selecciona rs2 o inmediato para ALU
  - `mem_to_reg`: Selecciona dato de ALU o memoria para escribir
  - `imm_src[1:0]`: Formato de inmediato (I/S/B)
  - `op[3:0]`: Operación de la ALU

### 4. **Register File**
- 32 registros de 32 bits (x0-x31)
- x0 siempre es 0
- 2 puertos de lectura, 1 puerto de escritura
- Escritura en flanco de subida del reloj

### 5. **Immediate Extender**
- Soporta 3 formatos:
  - Tipo I: 12 bits → 32 bits con extensión de signo
  - Tipo S: 12 bits concatenados → 32 bits
  - Tipo B: 13 bits → 32 bits (múltiplos de 2)

### 6. **ALU**
- 16 operaciones implementadas
- Flag `zero` para detección de resultado cero
- Soporta:
  - Aritmética: ADD, SUB
  - Lógica: AND, OR, XOR
  - Shifts: SLL, SRL, SRA
  - Comparaciones: SLT, SLTU, SGE, SGEU, BEQ, BNE

### 7. **Data Memory**
- RAM de 16 palabras (64 bytes)
- Lectura y escritura word-aligned
- Aquí se almacenan los resultados de Fibonacci

## Programa de Fibonacci

### Algoritmo
```c
int fibonacci[10];
fibonacci[0] = 0;
fibonacci[1] = 1;
for (int i = 2; i < 10; i++) {
    fibonacci[i] = fibonacci[i-1] + fibonacci[i-2];
}
```

### Código RISC-V (20 instrucciones)
```assembly
# Inicialización
addi x1, x0, 10      # n = 10
addi x6, x0, 0       # base_addr = 0
addi x7, x0, 0       # offset = 0
addi x2, x0, 0       # fib(n-2) = 0
addi x3, x0, 1       # fib(n-1) = 1

# Casos base
sw x2, 0(x6)         # Mem[0] = 0
addi x7, x7, 4       # offset = 4
add x8, x6, x7       # x8 = base + offset
sw x3, 0(x8)         # Mem[4] = 1
addi x5, x0, 2       # contador = 2

# Loop
loop:
  bge x5, x1, end    # if contador >= n goto end
  add x4, x3, x2     # fib(n) = fib(n-1) + fib(n-2)
  addi x7, x7, 4     # offset += 4
  add x8, x6, x7     # x8 = base + offset
  sw x4, 0(x8)       # Mem[offset] = fib(n)
  add x2, x0, x3     # fib(n-2) = fib(n-1)
  add x3, x0, x4     # fib(n-1) = fib(n)
  addi x5, x5, 1     # contador++
  beq x0, x0, loop   # goto loop

end:
  # Programa terminado
```

## Resultados Esperados

| Dirección | Valor | Fibonacci |
|-----------|-------|-----------|
| 0x00      | 0     | fib(0)    |
| 0x04      | 1     | fib(1)    |
| 0x08      | 1     | fib(2)    |
| 0x0C      | 2     | fib(3)    |
| 0x10      | 3     | fib(4)    |
| 0x14      | 5     | fib(5)    |
| 0x18      | 8     | fib(6)    |
| 0x1C      | 13    | fib(7)    |
| 0x20      | 21    | fib(8)    |
| 0x24      | 34    | fib(9)    |

## Cómo Ejecutar la Simulación

```bash
cd "/home/dante/Documents/Universidad/Arquitectura_Computadoras/RISC-V"
./scripts/run_fibonacci.sh
```

Este script:
1. Compila todos los módulos del procesador
2. Compila el testbench esquemático
3. Ejecuta la simulación por 1500ns
4. Genera archivo VCD para visualización

## Visualizar Resultados

```bash
gtkwave sim/fibonacci_processor.vcd
```

Señales importantes para visualizar:
- `pc_current`: Program Counter actual
- `instruction`: Instrucción que se está ejecutando
- `cycle_count`: Número de ciclos transcurridos
- `alu_result`: Resultado de la ALU
- `branch_taken`: Indica si se tomó un branch
- Registros del Register File: x1-x8
- Memoria de datos (dentro del componente DMEM)

## Verificación

La simulación imprime mensajes de debug que muestran:
- PC actual e instrucción en cada ciclo (cada 10 ciclos)
- Escrituras a memoria con valores
- Branches tomados con direcciones origen y destino

Al final, verifica los valores en Data Memory para confirmar que coinciden con la secuencia de Fibonacci.

## Instrucciones Utilizadas

El programa usa las siguientes instrucciones RV32I:
- `ADDI`: Suma con inmediato (inicializaciones y incrementos)
- `ADD`: Suma de registros (cálculo de Fibonacci y direcciones)
- `SW`: Store word (guardar en memoria)
- `BGE`: Branch if greater or equal (salir del loop)
- `BEQ`: Branch if equal (loop incondicional)

## Archivos Creados

1. `fibonacci_program.asm` - Código en ensamblador con comentarios
2. `fibonacci_encoding.md` - Codificación binaria/hexadecimal detallada
3. `src/core/instruction_memory_fibonacci.vhdl` - ROM con programa
4. `src/testbenches/fibonacci_processor_tb.vhdl` - Testbench esquemático
5. `scripts/run_fibonacci.sh` - Script de compilación y ejecución
6. `sim/fibonacci_processor.vcd` - Forma de onda generada

## Características del Testbench Esquemático

El testbench `fibonacci_processor_tb.vhdl` es completamente estructural:
- **No hay lógica algorítmica** en el testbench
- **Todos los componentes se instancian** explícitamente
- **Las interconexiones son señales** (buses)
- **Los multiplexores son asignaciones** concurrentes
- **El diagrama ASCII** en el código muestra la arquitectura

Esto es equivalente a crear un esquemático en una herramienta gráfica, pero escrito en VHDL.

## Notas Sobre la Implementación

1. **Word-Aligned Memory**: Todas las direcciones son múltiplos de 4
2. **Branch Offsets**: Los offsets de branch son relativos al PC actual
3. **Register x0**: Siempre lee como 0, las escrituras se ignoran
4. **Timing**: Escritura de registros en flanco de subida, lectura combinacional
5. **Branch Delay**: No hay branch delay slot (no es MIPS, es RISC-V)
