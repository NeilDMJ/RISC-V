# Corrección del Programa Fibonacci

## Problema Identificado
El programa entra en un loop infinito porque todos los valores de Fibonacci calculados son 1. Esto indica que el programa no está actualizando correctamente los valores.

## Análisis del Bug
Al revisar la salida:
- SW: Mem[00000000] = 0  ✓ (fib 0)
- SW: Mem[00000004] = 1  ✓ (fib 1)
- SW: Mem[00000008] = 1  ✓ (fib 2)
- SW: Mem[0000000C] = 1  ✗ (debería ser 2)
- Todos los demás son 1 ✗

El problema parece estar en cómo se están sumando o actualizando los valores.

## Instrucciones Problemáticas

Revisando el código:
```
add x4, x3, x2       # fib(n) = fib(n-1) + fib(n-2)
```

La instrucción ADD tipo R está codificada incorrectamente. 

### ADD x4, x3, x2 correcto:
- opcode: 0110011
- rd (x4): 00100
- func3: 000
- rs1 (x3): 00011
- rs2 (x2): 00010
- func7: 0000000

Binario: `0000000 00010 00011 000 00100 0110011`
Hex: `0x00218233` ✓ (Está correcto)

### Revisemos ADD x2, x0, x3:
- opcode: 0110011
- rd (x2): 00010  
- func3: 000
- rs1 (x0): 00000
- rs2 (x3): 00011
- func7: 0000000

Binario: `0000000 00011 00000 000 00010 0110011`
Hex: `0x003000B3` ✓

### Revisemos ADD x3, x0, x4:
- opcode: 0110011
- rd (x3): 00011
- func3: 000
- rs1 (x0): 00000
- rs2 (x4): 00100
- func7: 0000000

Binario: `0000000 00100 00000 000 00011 0110011`
Hex: `0x00400133` - INCORRECTO

Debería ser: `0x004001B3`

El problema es el rd (bits 11:7): debería ser 00011 (x3), pero en 0x00400133 es 00011.
Espera, eso está bien. Déjame verificar más cuidadosamente.

0x00400133 en binario:
00000000010000000000000100110011

Desglosado:
- func7 [31:25]: 0000000
- rs2 [24:20]: 00100 (x4) ✓
- rs1 [19:15]: 00000 (x0) ✓
- func3 [14:12]: 000
- rd [11:7]: 00011 (x3) ✓
- opcode [6:0]: 0110011 ✓

La codificación parece correcta. El problema debe estar en otro lado.
