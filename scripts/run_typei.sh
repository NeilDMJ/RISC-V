#!/bin/bash
# Script para simular instrucciones tipo I

echo "=== Simulación de instrucciones Tipo I ==="

# Directorio base
BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SRC_DIR="$BASE_DIR/src/core"
TB_DIR="$BASE_DIR/src/testbenches"
SIM_DIR="$BASE_DIR/sim"

# Crear directorio de simulación si no existe
mkdir -p "$SIM_DIR"

# Compilar
echo "Compilando módulos..."
cd "$SRC_DIR"
ghdl -a --std=08 alu.vhdl
ghdl -a --std=08 decoder.vhdl
ghdl -a --std=08 imm_extend.vhdl

cd "$TB_DIR"
ghdl -a --std=08 typei_tb.vhdl

# Elaborar
echo "Elaborando testbench..."
ghdl -e --std=08 tb_TypeI

# Simular
echo "Ejecutando simulación..."
ghdl -r --std=08 tb_TypeI --vcd="$SIM_DIR/wave_typei.vcd" --stop-time=500ns

echo ""
echo "✅ Simulación completada"
echo "Archivo VCD: $SIM_DIR/wave_typei.vcd"
echo ""
echo "Para visualizar en GTKWave:"
echo "  gtkwave $SIM_DIR/wave_typei.vcd"
