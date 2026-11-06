# Codificación del Programa Fibonacci en Binario/Hexadecimal

## Instrucciones Codificadas

| Línea | Instrucción Assembly | Binario | Hexadecimal | Dirección |
|-------|---------------------|---------|-------------|-----------|
| 1 | `addi x1, x0, 10` | `00000000101000000000000010010011` | `0x00A00093` | 0x00 |
| 2 | `addi x6, x0, 0` | `00000000000000000000001100010011` | `0x00000313` | 0x04 |
| 3 | `addi x7, x0, 0` | `00000000000000000000001110010011` | `0x00000393` | 0x08 |
| 4 | `addi x2, x0, 0` | `00000000000000000000000100010011` | `0x00000113` | 0x0C |
| 5 | `addi x3, x0, 1` | `00000000000100000000000110010011` | `0x00100193` | 0x10 |
| 6 | `sw x2, 0(x6)` | `00000000001000110010000000100011` | `0x00232023` | 0x14 |
| 7 | `addi x7, x7, 4` | `00000000010000111000001110010011` | `0x00438393` | 0x18 |
| 8 | `add x8, x6, x7` | `00000000011100110000010000110011` | `0x00730433` | 0x1C |
| 9 | `sw x3, 0(x8)` | `00000000001101000010000000100011` | `0x00342023` | 0x20 |
| 10 | `addi x5, x0, 2` | `00000000001000000000001010010011` | `0x00200293` | 0x24 |
| 11 | `bge x5, x1, 36` (end) | `00000000000100101101001001100011` | `0x0012D463` | 0x28 |
| 12 | `add x4, x3, x2` | `00000000001000011000001000110011` | `0x00218233` | 0x2C |
| 13 | `addi x7, x7, 4` | `00000000010000111000001110010011` | `0x00438393` | 0x30 |
| 14 | `add x8, x6, x7` | `00000000011100110000010000110011` | `0x00730433` | 0x34 |
| 15 | `sw x4, 0(x8)` | `00000000010001000010000000100011` | `0x00442023` | 0x38 |
| 16 | `add x2, x0, x3` | `00000000001100000000000100110011` | `0x003000B3` | 0x3C |
| 17 | `add x3, x0, x4` | `00000000010000000000000110110011` | `0x00400133` | 0x40 |
| 18 | `addi x5, x5, 1` | `00000000000100101000001010010011` | `0x00128293` | 0x44 |
| 19 | `beq x0, x0, -32` (loop) | `11111110000000000000000001100011` | `0xFE000063` | 0x48 |
| 20 | `addi x0, x0, 0` (NOP) | `00000000000000000000000000010011` | `0x00000013` | 0x4C |

## Detalles de Codificación

### Instrucción 11: BGE (Branch if Greater or Equal)
```
bge x5, x1, 36
- Offset real = 36 bytes desde PC actual
- PC actual = 0x28
- PC destino = 0x28 + 36 = 0x4C (dirección "end")
- Offset en formato B: 36 = 0b000000100100 (12 bits con LSB implícito en 0)
  - imm[12] = 0
  - imm[10:5] = 000001
  - imm[4:1] = 0010
  - imm[11] = 0
```

### Instrucción 19: BEQ (salto incondicional hacia atrás)
```
beq x0, x0, -32
- Offset real = -32 bytes (0xFFFFFFE0 en complemento a 2)
- PC actual = 0x48
- PC destino = 0x48 - 32 = 0x28 (dirección "loop")
- Offset en formato B: -32 = 0b1111111100000
  - imm[12] = 1
  - imm[10:5] = 111111
  - imm[4:1] = 0000
  - imm[11] = 1
```

## Valores Esperados en Memoria al Final

| Dirección | Valor Decimal | Valor Hexadecimal | Fibonacci |
|-----------|---------------|-------------------|-----------|
| 0x00 | 0 | 0x00000000 | fib(0) |
| 0x04 | 1 | 0x00000001 | fib(1) |
| 0x08 | 1 | 0x00000001 | fib(2) |
| 0x0C | 2 | 0x00000002 | fib(3) |
| 0x10 | 3 | 0x00000003 | fib(4) |
| 0x14 | 5 | 0x00000005 | fib(5) |
| 0x18 | 8 | 0x00000008 | fib(6) |
| 0x1C | 13 | 0x0000000D | fib(7) |
| 0x20 | 21 | 0x00000015 | fib(8) |
| 0x24 | 34 | 0x00000022 | fib(9) |

## Mapeo de Registros

| Registro | Alias | Uso en el Programa |
|----------|-------|--------------------|
| x0 | zero | Constante cero |
| x1 | t0 | n = cantidad de números a calcular |
| x2 | t1 | fib(n-2) |
| x3 | t2 | fib(n-1) |
| x4 | t3 | fib(n) actual |
| x5 | t4 | Contador del loop |
| x6 | t5 | Dirección base de memoria |
| x7 | t6 | Offset para direccionamiento |
| x8 | s0 | Dirección efectiva (temporal) |
