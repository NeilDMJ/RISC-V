#!/bin/bash

# Script para compilar y ejecutar el testbench completo de RISC-V

echo "======================================"
echo "Compilando testbench RISC-V completo"
echo "======================================"

# Limpiar archivos previos
rm -f sim/riscv_complete.vcd
rm -f work-obj08.cf

# Compilar componentes del core
echo "Compilando componentes del core..."
ghdl -a --std=08 src/core/decoder.vhdl
ghdl -a --std=08 src/core/register_file.vhdl
ghdl -a --std=08 src/core/alu.vhdl
ghdl -a --std=08 src/core/imm_extend.vhdl
ghdl -a --std=08 src/core/data_memory.vhdl

# Compilar testbench
echo "Compilando testbench..."
ghdl -a --std=08 src/testbenches/riscv_complete_tb.vhdl

# Elaborar
echo "Elaborando..."
ghdl -e --std=08 riscv_complete_tb

# Ejecutar y generar waveform
echo "Ejecutando simulacion..."
ghdl -r --std=08 riscv_complete_tb --vcd=sim/riscv_complete.vcd --stop-time=500ns

echo ""
echo "======================================"
echo "Simulacion completada"
echo "======================================"
echo "Archivo VCD generado: sim/riscv_complete.vcd"
echo ""
echo "Para ver el waveform ejecuta:"
echo "  gtkwave sim/riscv_complete.vcd"
echo ""
