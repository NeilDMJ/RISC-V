#!/bin/bash

# Script para compilar y ejecutar el testbench de instrucciones BRANCH
# Este script prueba las 6 instrucciones de salto condicional tipo B

echo "======================================"
echo "  RISC-V Branch Instructions Test"
echo "======================================"
echo ""

# Directorio del proyecto
PROJECT_DIR="/home/dante/Documents/Universidad/Arquitectura_Computadoras/RISC-V"
cd "$PROJECT_DIR"

echo "Compilando módulos core..."

# Compilar los módulos en el orden correcto
ghdl -a --std=08 src/core/alu.vhdl
if [ $? -ne 0 ]; then
    echo "Error compilando ALU"
    exit 1
fi

ghdl -a --std=08 src/core/decoder.vhdl
if [ $? -ne 0 ]; then
    echo "Error compilando Decoder"
    exit 1
fi

ghdl -a --std=08 src/core/imm_extend.vhdl
if [ $? -ne 0 ]; then
    echo "Error compilando ImmExtend"
    exit 1
fi

echo "Compilando testbench de branches..."
ghdl -a --std=08 src/testbenches/branch_tb.vhdl
if [ $? -ne 0 ]; then
    echo "Error compilando testbench de branches"
    exit 1
fi

echo "Elaborando diseño..."
ghdl -e --std=08 branch_tb
if [ $? -ne 0 ]; then
    echo "Error en elaboración"
    exit 1
fi

echo ""
echo "Ejecutando simulación..."
echo "--------------------------------------"
ghdl -r --std=08 branch_tb --vcd=sim/branch_test.vcd
if [ $? -ne 0 ]; then
    echo "Error en ejecución"
    exit 1
fi

echo ""
echo "======================================"
echo "  Simulación completada exitosamente"
echo "======================================"
echo ""
echo "Archivo VCD generado: sim/branch_test.vcd"
echo "Para visualizar: gtkwave sim/branch_test.vcd"
