#!/bin/bash

# Script para compilar y ejecutar el procesador RISC-V con Fibonacci
# Este script simula la ejecución completa del algoritmo de Fibonacci

echo "=========================================================================="
echo "  PROCESADOR RISC-V - SIMULACIÓN DEL ALGORITMO DE FIBONACCI"
echo "=========================================================================="
echo ""

# Directorio del proyecto
PROJECT_DIR="/home/dante/Documents/Universidad/Arquitectura_Computadoras/RISC-V"
cd "$PROJECT_DIR"

# Crear directorio de simulación si no existe
mkdir -p sim

echo "Paso 1: Compilando módulos core del procesador..."
echo "----------------------------------------------------------------"

# Compilar todos los módulos en orden de dependencias
ghdl -a --std=08 src/core/alu.vhdl
if [ $? -ne 0 ]; then
    echo "❌ Error compilando ALU"
    exit 1
fi
echo "✓ ALU compilado"

ghdl -a --std=08 src/core/decoder.vhdl
if [ $? -ne 0 ]; then
    echo "❌ Error compilando Decoder"
    exit 1
fi
echo "✓ Decoder compilado"

ghdl -a --std=08 src/core/imm_extend.vhdl
if [ $? -ne 0 ]; then
    echo "❌ Error compilando ImmExtend"
    exit 1
fi
echo "✓ ImmExtend compilado"

ghdl -a --std=08 src/core/register_file.vhdl
if [ $? -ne 0 ]; then
    echo "❌ Error compilando Register File"
    exit 1
fi
echo "✓ Register File compilado"

ghdl -a --std=08 src/core/data_memory.vhdl
if [ $? -ne 0 ]; then
    echo "❌ Error compilando Data Memory"
    exit 1
fi
echo "✓ Data Memory compilado"

ghdl -a --std=08 src/core/program_counter.vhdl
if [ $? -ne 0 ]; then
    echo "❌ Error compilando Program Counter"
    exit 1
fi
echo "✓ Program Counter compilado"

ghdl -a --std=08 src/core/instruction_memory_fibonacci.vhdl
if [ $? -ne 0 ]; then
    echo "❌ Error compilando Instruction Memory (Fibonacci)"
    exit 1
fi
echo "✓ Instruction Memory (Fibonacci) compilado"

echo ""
echo "Paso 2: Compilando testbench esquemático..."
echo "----------------------------------------------------------------"

ghdl -a --std=08 src/testbenches/fibonacci_processor_tb.vhdl
if [ $? -ne 0 ]; then
    echo "❌ Error compilando testbench de Fibonacci"
    exit 1
fi
echo "✓ Testbench compilado"

echo ""
echo "Paso 3: Elaborando diseño..."
echo "----------------------------------------------------------------"

ghdl -e --std=08 fibonacci_processor_tb
if [ $? -ne 0 ]; then
    echo "❌ Error en elaboración"
    exit 1
fi
echo "✓ Diseño elaborado correctamente"

echo ""
echo "Paso 4: Ejecutando simulación..."
echo "=================================================================="
echo ""

# Ejecutar simulación y generar archivo VCD
ghdl -r --std=08 fibonacci_processor_tb --vcd=sim/fibonacci_processor.vcd --stop-time=1500ns
RESULT=$?

echo ""
echo "=================================================================="

if [ $RESULT -eq 0 ]; then
    echo "✓ Simulación completada exitosamente"
    echo ""
    echo "Archivos generados:"
    echo "  - sim/fibonacci_processor.vcd  (forma de onda)"
    echo ""
    echo "Para visualizar la forma de onda:"
    echo "  gtkwave sim/fibonacci_processor.vcd"
    echo ""
    echo "Valores esperados en Data Memory:"
    echo "  Mem[0x00] = 0   (Fibonacci 0)"
    echo "  Mem[0x04] = 1   (Fibonacci 1)"
    echo "  Mem[0x08] = 1   (Fibonacci 2)"
    echo "  Mem[0x0C] = 2   (Fibonacci 3)"
    echo "  Mem[0x10] = 3   (Fibonacci 4)"
    echo "  Mem[0x14] = 5   (Fibonacci 5)"
    echo "  Mem[0x18] = 8   (Fibonacci 6)"
    echo "  Mem[0x1C] = 13  (Fibonacci 7)"
    echo "  Mem[0x20] = 21  (Fibonacci 8)"
    echo "  Mem[0x24] = 34  (Fibonacci 9)"
    echo ""
    echo "=========================================================================="
else
    echo "❌ Error durante la simulación"
    exit 1
fi
