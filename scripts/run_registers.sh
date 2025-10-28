#!/bin/bash
# Script para simular el banco de registros

echo "=== Simulación del Banco de Registros ==="

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
ghdl -a --std=08 register_file.vhdl

cd "$TB_DIR"
ghdl -a --std=08 register_file_tb.vhdl

# Elaborar
echo "Elaborando testbench..."
ghdl -e --std=08 BancoDeRegistros_tb

# Simular
echo "Ejecutando simulación..."
ghdl -r --std=08 BancoDeRegistros_tb --vcd="$SIM_DIR/wave_registers.vcd" --stop-time=500ns

echo ""
echo "✅ Simulación completada"
echo "Archivo VCD: $SIM_DIR/wave_registers.vcd"
echo ""
echo "Para visualizar en GTKWave:"
echo "  gtkwave $SIM_DIR/wave_registers.vcd"
