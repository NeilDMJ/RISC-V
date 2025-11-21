# Programa: Cálculo de la sucesión de Fibonacci en RISC-V
# Calcula los primeros N números de Fibonacci y los almacena en memoria
#
# Registros utilizados:
#   x1 (t0) = n (cantidad de números a calcular)
#   x2 (t1) = fib(n-2) (número anterior al anterior)
#   x3 (t2) = fib(n-1) (número anterior)
#   x4 (t3) = fib(n) (número actual)
#   x5 (t4) = contador del loop
#   x6 (t5) = dirección base de memoria
#   x7 (t6) = offset para almacenar en memoria

# Inicialización
main:
    addi x1, x0, 10      # n = 10 (calcular 10 números de Fibonacci)
    addi x6, x0, 0       # dirección base de memoria = 0
    addi x7, x0, 0       # offset inicial = 0
    
    # Casos base: fib(0) = 0, fib(1) = 1
    addi x2, x0, 0       # fib(0) = 0
    addi x3, x0, 1       # fib(1) = 1
    
    # Guardar fib(0) en memoria[0]
    sw x2, 0(x6)         # Mem[0] = 0
    
    # Guardar fib(1) en memoria[4]
    addi x7, x7, 4       # offset = 4
    add x8, x6, x7       # x8 = dirección base + offset
    sw x3, 0(x8)         # Mem[4] = 1
    
    # Inicializar contador
    addi x5, x0, 2       # contador = 2 (ya calculamos fib(0) y fib(1))

loop:
    # Verificar si contador >= n
    bge x5, x1, end      # if (contador >= n) goto end
    
    # Calcular fib(n) = fib(n-1) + fib(n-2)
    add x4, x3, x2       # x4 = fib(n) = fib(n-1) + fib(n-2)
    
    # Guardar fib(n) en memoria
    addi x7, x7, 4       # incrementar offset
    add x8, x6, x7       # x8 = dirección base + offset
    sw x4, 0(x8)         # Mem[offset] = fib(n)
    
    # Actualizar valores para siguiente iteración
    add x2, x0, x3       # fib(n-2) = fib(n-1)
    add x3, x0, x4       # fib(n-1) = fib(n)
    
    # Incrementar contador
    addi x5, x5, 1       # contador++
    
    # Volver al inicio del loop
    beq x0, x0, loop     # goto loop (salto incondicional usando BEQ con x0 == x0)

end:
    # Programa terminado
    # Los resultados están en memoria:
    # Mem[0] = 0, Mem[4] = 1, Mem[8] = 1, Mem[12] = 2,
    # Mem[16] = 3, Mem[20] = 5, Mem[24] = 8, Mem[28] = 13,
    # Mem[32] = 21, Mem[36] = 34

# Secuencia de Fibonacci esperada (primeros 10 números):
# fib(0) = 0
# fib(1) = 1
# fib(2) = 1
# fib(3) = 2
# fib(4) = 3
# fib(5) = 5
# fib(6) = 8
# fib(7) = 13
# fib(8) = 21
# fib(9) = 34
