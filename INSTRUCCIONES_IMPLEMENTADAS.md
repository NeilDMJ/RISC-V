# Instrucciones RISC-V RV32I Implementadas

Este documento lista todas las instrucciones del conjunto RV32I que están implementadas en el procesador.

## Resumen por Tipo

- **Tipo R** (Register-Register): 10 instrucciones
- **Tipo I** (Immediate): 8 instrucciones  
- **Tipo L** (Load): 5 instrucciones
- **Tipo S** (Store): 3 instrucciones
- **Tipo B** (Branch): 6 instrucciones
- **TOTAL**: 32 instrucciones

---

## Instrucciones Tipo R (opcode: 0110011)

Operan entre dos registros y escriben el resultado en un tercer registro.

| Instrucción | func3 | func7    | Operación ALU | Descripción |
|-------------|-------|----------|---------------|-------------|
| `add`       | 000   | 0000000  | 0000          | rd = rs1 + rs2 |
| `sub`       | 000   | 0100000  | 0001          | rd = rs1 - rs2 |
| `sll`       | 001   | 0000000  | 0010          | rd = rs1 << rs2[4:0] (shift left logical) |
| `slt`       | 010   | 0000000  | 1000          | rd = (rs1 < rs2) ? 1 : 0 (signed) |
| `sltu`      | 011   | 0000000  | 1001          | rd = (rs1 < rs2) ? 1 : 0 (unsigned) |
| `xor`       | 100   | 0000000  | 0101          | rd = rs1 XOR rs2 |
| `srl`       | 101   | 0000000  | 0011          | rd = rs1 >> rs2[4:0] (shift right logical) |
| `sra`       | 101   | 0100000  | 0100          | rd = rs1 >> rs2[4:0] (shift right arithmetic) |
| `or`        | 110   | 0000000  | 0110          | rd = rs1 OR rs2 |
| `and`       | 111   | 0000000  | 0111          | rd = rs1 AND rs2 |

**Señales de control:**
- `reg_we = 1` (escribir en registro destino)
- `mem_we = 0` (no escribir en memoria)
- `alu_src = 0` (usar rs2)
- `mem_to_reg = 0` (resultado viene de ALU)
- `imm_src = 00` (no usado)

---

## Instrucciones Tipo I (opcode: 0010011)

Operan con un registro y un inmediato de 12 bits.

| Instrucción | func3 | func7/shamt | Operación ALU | Descripción |
|-------------|-------|-------------|---------------|-------------|
| `addi`      | 000   | -           | 0000          | rd = rs1 + imm |
| `xori`      | 100   | -           | 0101          | rd = rs1 XOR imm |
| `ori`       | 110   | -           | 0110          | rd = rs1 OR imm |
| `andi`      | 111   | -           | 0111          | rd = rs1 AND imm |
| `slli`      | 001   | 0000000     | 0010          | rd = rs1 << shamt |
| `srli`      | 101   | 0000000     | 0011          | rd = rs1 >> shamt (logical) |
| `srai`      | 101   | 0100000     | 0100          | rd = rs1 >> shamt (arithmetic) |
| `slti`      | 010   | -           | 1000          | rd = (rs1 < imm) ? 1 : 0 (signed) |
| `sltiu`     | 011   | -           | 1001          | rd = (rs1 < imm) ? 1 : 0 (unsigned) |

**Señales de control:**
- `reg_we = 1` (escribir en registro destino)
- `mem_we = 0` (no escribir en memoria)
- `alu_src = 1` (usar inmediato extendido)
- `mem_to_reg = 0` (resultado viene de ALU)
- `imm_src = 00` (formato tipo I)

---

## Instrucciones Tipo L (opcode: 0000011)

Cargan datos de memoria a un registro.

| Instrucción | func3 | Operación ALU | Descripción |
|-------------|-------|---------------|-------------|
| `lb`        | 000   | 0000          | rd = SignExt(Mem[rs1 + imm][7:0]) |
| `lh`        | 001   | 0000          | rd = SignExt(Mem[rs1 + imm][15:0]) |
| `lw`        | 010   | 0000          | rd = Mem[rs1 + imm] |
| `lbu`       | 100   | 0000          | rd = ZeroExt(Mem[rs1 + imm][7:0]) |
| `lhu`       | 101   | 0000          | rd = ZeroExt(Mem[rs1 + imm][15:0]) |

**Señales de control:**
- `reg_we = 1` (escribir en registro destino)
- `mem_we = 0` (no escribir en memoria, solo leer)
- `alu_src = 1` (usar inmediato para calcular dirección)
- `mem_to_reg = 1` (dato viene de memoria)
- `imm_src = 00` (formato tipo I)

**Nota:** La ALU calcula la dirección efectiva: `dirección = rs1 + inmediato`

---

## Instrucciones Tipo S (opcode: 0100011)

Almacenan datos de un registro en memoria.

| Instrucción | func3 | Operación ALU | Descripción |
|-------------|-------|---------------|-------------|
| `sb`        | 000   | 0000          | Mem[rs1 + imm][7:0] = rs2[7:0] |
| `sh`        | 001   | 0000          | Mem[rs1 + imm][15:0] = rs2[15:0] |
| `sw`        | 010   | 0000          | Mem[rs1 + imm] = rs2 |

**Señales de control:**
- `reg_we = 0` (NO escribir en registro)
- `mem_we = 1` (escribir en memoria)
- `alu_src = 1` (usar inmediato para calcular dirección)
- `mem_to_reg = 0` (no usado)
- `imm_src = 01` (formato tipo S: imm[11:0] = instr[31:25] & instr[11:7])

**Nota:** El inmediato tipo S tiene formato especial: bits [31:25] + bits [11:7]

---

## Instrucciones Tipo B (opcode: 1100011)

Saltos condicionales basados en comparación de registros.

| Instrucción | func3 | Operación ALU | Descripción |
|-------------|-------|---------------|-------------|
| `beq`       | 000   | 1100          | if (rs1 == rs2) PC = PC + imm |
| `bne`       | 001   | 1101          | if (rs1 != rs2) PC = PC + imm |
| `blt`       | 100   | 1000          | if (rs1 < rs2) PC = PC + imm (signed) |
| `bge`       | 101   | 1010          | if (rs1 >= rs2) PC = PC + imm (signed) |
| `bltu`      | 110   | 1001          | if (rs1 < rs2) PC = PC + imm (unsigned) |
| `bgeu`      | 111   | 1011          | if (rs1 >= rs2) PC = PC + imm (unsigned) |

**Señales de control:**
- `reg_we = 0` (NO escribir en registro)
- `mem_we = 0` (NO escribir en memoria)
- `alu_src = 0` (comparar rs1 con rs2)
- `mem_to_reg = 0` (no usado)
- `imm_src = 10` (formato tipo B: imm[12:0] = instr[31] & instr[7] & instr[30:25] & instr[11:8] & 0)

**Nota:** La ALU retorna 1 en el bit menos significativo si la condición es verdadera.

---

## Mapeo de Operaciones de la ALU

| Código | Operación | Descripción |
|--------|-----------|-------------|
| 0000   | ADD       | Suma |
| 0001   | SUB       | Resta |
| 0010   | SLL       | Shift left logical |
| 0011   | SRL       | Shift right logical |
| 0100   | SRA       | Shift right arithmetic |
| 0101   | XOR       | XOR lógico |
| 0110   | OR        | OR lógico |
| 0111   | AND       | AND lógico |
| 1000   | SLT       | Set less than (signed) |
| 1001   | SLTU      | Set less than unsigned |
| 1010   | SGE       | Set greater or equal (signed) |
| 1011   | SGEU      | Set greater or equal unsigned |
| 1100   | BEQ       | Branch if equal |
| 1101   | BNE       | Branch if not equal |
| 1110   | PASS2     | Pass do2 (para LUI/AUIPC) |
| 1111   | PASS1     | Pass do1 (para JAL/JALR) |

---

## Señales de Control del Decoder

| Señal       | Bits | Valores | Descripción |
|-------------|------|---------|-------------|
| `reg_we`    | 1    | 0/1     | Write enable del banco de registros |
| `mem_we`    | 1    | 0/1     | Write enable de la memoria de datos |
| `alu_src`   | 1    | 0/1     | Selector de operando 2 de ALU (0=rs2, 1=imm) |
| `mem_to_reg`| 1    | 0/1     | Selector de dato a escribir (0=ALU, 1=mem) |
| `imm_src`   | 2    | 00/01/10| Selector de formato de inmediato (00=I, 01=S, 10=B) |
| `op`        | 4    | 0000-1111 | Código de operación de la ALU |

---

## Formatos de Inmediatos

### Tipo I (imm_src = 00)
```
imm[11:0] = instr[31:20]
Extensión de signo a 32 bits
```

### Tipo S (imm_src = 01)
```
imm[11:5] = instr[31:25]
imm[4:0]  = instr[11:7]
Extensión de signo a 32 bits
```

### Tipo B (imm_src = 10)
```
imm[12]   = instr[31]
imm[11]   = instr[7]
imm[10:5] = instr[30:25]
imm[4:1]  = instr[11:8]
imm[0]    = 0 (siempre)
Extensión de signo a 32 bits
```

---

## Verificación de Cobertura

✅ **32 instrucciones implementadas** según `instrucciones.txt`:

### Tipo R (10/10)
✅ add, sub, xor, or, sll, srl, sra, slt, sltu, and

### Tipo I (8/8)
✅ addi, xori, ori, andi, slli, srli, srai, slti, sltiu

### Tipo L (5/5)
✅ lb, lh, lw, lbu, lhu

### Tipo S (3/3)
✅ sb, sh, sw

### Tipo B (6/6)
✅ beq, bne, blt, bge, bltu, bgeu

---

## Notas de Implementación

1. **ALU con flag zero:** La ALU incluye una salida `zero` que se activa cuando el resultado es cero, útil para branches.

2. **Reutilización de hardware:** Las instrucciones de branch (BLT, BLTU, BGE, BGEU) reutilizan las comparaciones SLT, SLTU, SGE, SGEU respectivamente.

3. **Inmediato tipo B:** El bit menos significativo del inmediato tipo B siempre es 0, garantizando que los offsets de branch sean múltiplos de 2.

4. **Extensión de signo:** Todos los inmediatos usan extensión de signo para preservar valores negativos.

5. **Direccionamiento de memoria:** Las direcciones de memoria se calculan como `rs1 + inmediato` usando la ALU en modo suma.
