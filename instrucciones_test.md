# Instrucciones de Prueba RISC-V

## Tabla de Instrucciones

| Tipo | # | Instrucción Ensamblador | Instrucción Binaria (32 bits) | Descripción |
|------|---|------------------------|-------------------------------|-------------|
| **R** | 1 | `add x3, x1, x2` | `0000000_00010_00001_000_00011_0110011` | x3 = x1 + x2 |
| **R** | 2 | `sub x5, x3, x4` | `0100000_00100_00011_000_00101_0110011` | x5 = x3 - x4 |
| **R** | 3 | `and x7, x5, x6` | `0000000_00110_00101_111_00111_0110011` | x7 = x5 AND x6 |
| **I** | 1 | `addi x8, x0, 10` | `000000001010_00000_000_01000_0010011` | x8 = x0 + 10 |
| **I** | 2 | `xori x9, x8, 15` | `000000001111_01000_100_01001_0010011` | x9 = x8 XOR 15 |
| **I** | 3 | `ori x10, x9, 7` | `000000000111_01001_110_01010_0010011` | x10 = x9 OR 7 |
| **L** | 1 | `lw x11, 0(x8)` | `000000000000_01000_010_01011_0000011` | x11 = Mem[x8 + 0] |
| **L** | 2 | `lw x12, 4(x10)` | `000000000100_01010_010_01100_0000011` | x12 = Mem[x10 + 4] |
| **S** | 1 | `sw x11, 0(x8)` | `0000000_01011_01000_010_00000_0100011` | Mem[x8 + 0] = x11 |
| **S** | 2 | `sw x12, 8(x10)` | `0000000_01100_01010_010_01000_0100011` | Mem[x10 + 8] = x12 |

## Formato de Instrucciones

### Tipo R (Registro-Registro)
```
funct7 (7) | rs2 (5) | rs1 (5) | funct3 (3) | rd (5) | opcode (7)
```

### Tipo I (Inmediato)
```
imm[11:0] (12) | rs1 (5) | funct3 (3) | rd (5) | opcode (7)
```

### Tipo L (Load - es un subtipo de I)
```
imm[11:0] (12) | rs1 (5) | funct3 (3) | rd (5) | opcode (7)
```

### Tipo S (Store)
```
imm[11:5] (7) | rs2 (5) | rs1 (5) | funct3 (3) | imm[4:0] (5) | opcode (7)
```

## Instrucciones en Formato Hexadecimal

| Tipo | Instrucción | Hexadecimal |
|------|-------------|-------------|
| R | `add x3, x1, x2` | `0x002081B3` |
| R | `sub x5, x3, x4` | `0x404182B3` |
| R | `and x7, x5, x6` | `0x0062F3B3` |
| I | `addi x8, x0, 10` | `0x00A00413` |
| I | `xori x9, x8, 15` | `0x00F44493` |
| I | `ori x10, x9, 7` | `0x0074E513` |
| L | `lw x11, 0(x8)` | `0x00042583` |
| L | `lw x12, 4(x10)` | `0x00452603` |
| S | `sw x11, 0(x8)` | `0x00B42023` |
| S | `sw x12, 8(x10)` | `0x00C52423` |

## Notas

- Los registros utilizados varían para evitar conflictos de dependencias
- Las instrucciones Load usan diferentes offsets (0 y 4)
- Las instrucciones Store usan diferentes offsets (0 y 8)
- Los valores inmediatos son diferentes en cada instrucción tipo I
- Todas las instrucciones están codificadas según el estándar RISC-V RV32I

```
./scripts/run_complete.sh
gtkwave sim/riscv_complete.vcd scripts/wave_complete.gtkw
```