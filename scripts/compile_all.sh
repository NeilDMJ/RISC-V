#!/bin/bash
# Script para compilar todos los módulos del procesador RISC-V

echo "=== Compilando módulos del procesador RISC-V ==="

# Directorio base
BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SRC_DIR="$BASE_DIR/src/core"
TB_DIR="$BASE_DIR/src/testbenches"
SIM_DIR="$BASE_DIR/sim"

# Crear directorio de simulación si no existe
mkdir -p "$SIM_DIR"

# Limpiar archivos anteriores
echo "Limpiando archivos de compilación anteriores..."
cd "$BASE_DIR"
rm -f *.o *.cf work-*.cf

echo ""
echo "=== Compilando módulos core ==="
cd "$SRC_DIR"

ghdl -a --std=08 alu.vhdl
ghdl -a --std=08 decoder.vhdl
ghdl -a --std=08 imm_extend.vhdl
ghdl -a --std=08 register_file.vhdl
ghdl -a --std=08 data_memory.vhdl

echo ""
echo "=== Compilando testbenches ==="
cd "$TB_DIR"

ghdl -a --std=08 alu_decoder_tb.vhdl
ghdl -a --std=08 typei_tb.vhdl
ghdl -a --std=08 register_file_tb.vhdl

echo ""
echo "Compilación completada exitosamente"
echo ""
echo "Para ejecutar simulaciones:"
echo "  - Tipo I:  cd scripts && ./run_typei.sh"
echo "  - Tipo R:  cd scripts && ./run_typer.sh"
echo "  - Registros: cd scripts && ./run_registers.sh"
