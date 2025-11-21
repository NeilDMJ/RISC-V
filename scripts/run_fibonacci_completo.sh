#!/bin/bash

# Script para compilar y ejecutar el testbench del procesador completo con Fibonacci
# Versión actualizada para la arquitectura con branch_unit

echo "=========================================================================="
echo "  RISC-V PROCESADOR COMPLETO - SIMULACIÓN FIBONACCI"
echo "=========================================================================="
echo ""

PROJECT_DIR="/home/dante/Documents/Universidad/Arquitectura_Computadoras/RISC-V"
cd "$PROJECT_DIR"

mkdir -p sim

echo "Paso 1: Compilando módulos básicos..."
echo "----------------------------------------------------------------------"

# Compilar ALU
ghdl -a --std=08 src/core/alu.vhdl
if [ $? -ne 0 ]; then echo "❌ Error en ALU"; exit 1; fi
echo "✓ ALU"

# Compilar Decoder actualizado
ghdl -a --std=08 src/core/decoder.vhd
if [ $? -ne 0 ]; then echo "❌ Error en Decoder"; exit 1; fi
echo "✓ Decoder (con branch)"

# Compilar ImmExtend (el original .vhdl)
ghdl -a --std=08 src/core/imm_extend.vhdl
if [ $? -ne 0 ]; then echo "❌ Error en ImmExtend"; exit 1; fi
echo "✓ ImmExtend"

# Compilar Register File
ghdl -a --std=08 src/core/register_file.vhdl
if [ $? -ne 0 ]; then echo "❌ Error en Register File"; exit 1; fi
echo "✓ Register File"

echo ""
echo "Paso 2: Compilando módulos auxiliares..."
echo "----------------------------------------------------------------------"

# Concatenador
ghdl -a --std=08 src/core/concatenator_7_5.vhdl
if [ $? -ne 0 ]; then echo "❌ Error en Concatenator"; exit 1; fi
echo "✓ Concatenator"

# MUX 2 to 1
ghdl -a --std=08 src/core/mux2to1.vhdl
if [ $? -ne 0 ]; then echo "❌ Error en MUX2to1"; exit 1; fi
echo "✓ MUX 2-to-1"

echo ""
echo "Paso 3: Compilando módulos de memoria y PC..."
echo "----------------------------------------------------------------------"

# Data Memory actualizada
ghdl -a --std=08 src/core/data_mem.vhd
if [ $? -ne 0 ]; then echo "❌ Error en Data Memory"; exit 1; fi
echo "✓ Data Memory"

# Instruction Memory con Fibonacci
ghdl -a --std=08 src/core/Instr_mem.vhd
if [ $? -ne 0 ]; then echo "❌ Error en Instruction Memory"; exit 1; fi
echo "✓ Instruction Memory (Fibonacci)"

# PC Register
ghdl -a --std=08 src/core/pc_reg.vhd
if [ $? -ne 0 ]; then echo "❌ Error en PC Register"; exit 1; fi
echo "✓ PC Register"

echo ""
echo "Paso 4: Compilando módulos de branch..."
echo "----------------------------------------------------------------------"

# Branch Immediate Extend
ghdl -a --std=08 src/core/branch_imm_extend.vhd
if [ $? -ne 0 ]; then echo "❌ Error en Branch Imm Extend"; exit 1; fi
echo "✓ Branch Imm Extend"

# Branch Unit
ghdl -a --std=08 src/core/branch_unit.vhd
if [ $? -ne 0 ]; then echo "❌ Error en Branch Unit"; exit 1; fi
echo "✓ Branch Unit"

echo ""
echo "Paso 5: Compilando módulo top completo..."
echo "----------------------------------------------------------------------"

ghdl -a --std=08 src/core/completo.vhd
if [ $? -ne 0 ]; then echo "❌ Error en Completo Top"; exit 1; fi
echo "✓ Completo Top"

echo ""
echo "Paso 6: Compilando testbench..."
echo "----------------------------------------------------------------------"

ghdl -a --std=08 src/testbenches/tb_fibonacci_completo.vhdl
if [ $? -ne 0 ]; then echo "❌ Error en Testbench"; exit 1; fi
echo "✓ Testbench"

echo ""
echo "Paso 7: Elaborando diseño..."
echo "----------------------------------------------------------------------"

ghdl -e --std=08 tb_fibonacci_completo
if [ $? -ne 0 ]; then echo "❌ Error en elaboración"; exit 1; fi
echo "✓ Elaboración exitosa"

echo ""
echo "Paso 8: Ejecutando simulación..."
echo "======================================================================"
echo ""

ghdl -r --std=08 tb_fibonacci_completo --vcd=sim/fibonacci_completo.vcd --stop-time=2000ns
RESULT=$?

echo ""
echo "======================================================================"

if [ $RESULT -eq 0 ]; then
    echo "✅ SIMULACIÓN COMPLETADA EXITOSAMENTE"
    echo ""
    echo "Archivos generados:"
    echo "  📊 sim/fibonacci_completo.vcd"
    echo ""
    echo "Para visualizar:"
    echo "  gtkwave sim/fibonacci_completo.vcd"
    echo ""
    echo "Señales importantes para visualizar:"
    echo "  • DUT.pc_value           - Program Counter"
    echo "  • DUT.instr              - Instrucción actual"
    echo "  • DUT.rf_do1 / rf_do2    - Datos de registros"
    echo "  • DUT.alu_result         - Resultado ALU"
    echo "  • DUT.branch_taken       - Branch tomado"
    echo "  • DUT.U_DMEM.mem         - Memoria de datos (Fibonacci)"
    echo ""
    echo "Programa ejecutado:"
    echo "  n = 7 números de Fibonacci"
    echo "  Algoritmo iterativo con variables a y b"
    echo "  Resultados almacenados en memoria secuencialmente"
    echo ""
    echo "=========================================================================="
else
    echo "❌ Error durante la simulación"
    exit 1
fi
