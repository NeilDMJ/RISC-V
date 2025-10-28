#!/bin/bash
# Script para simular instrucciones tipo R

echo "=== Simulación de instrucciones Tipo R ==="

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

cd "$TB_DIR"
ghdl -a --std=08 alu_decoder_tb.vhdl

# Elaborar
echo "Elaborando testbench..."
ghdl -e --std=08 tb_ALU_Decoder

# Simular
echo "Ejecutando simulación..."
ghdl -r --std=08 tb_ALU_Decoder --vcd="$SIM_DIR/wave_typer.vcd" --stop-time=200ns

echo ""
echo "✅ Simulación completada"
echo "Archivo VCD: $SIM_DIR/wave_typer.vcd"
echo ""
echo "Para visualizar en GTKWave:"
echo "  gtkwave $SIM_DIR/wave_typer.vcd"
