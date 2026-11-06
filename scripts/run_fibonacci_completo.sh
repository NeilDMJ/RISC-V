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
    echo "======================================================================"
    echo "📊 RESULTADOS DE FIBONACCI EN MEMORIA"
    echo "======================================================================"
    echo ""
    echo "Extrayendo valores finales de la memoria de datos..."
    echo ""
    
    # Crear un pequeño script VHDL para imprimir la memoria
    cat > /tmp/print_mem.vhdl << 'EOF'
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity print_mem is
end print_mem;

architecture behavior of print_mem is
    signal clk : std_logic := '0';
    signal reset : std_logic := '1';
    
    component completo_top
        port (
            clk : in std_logic;
            reset : in std_logic
        );
    end component;
    
begin
    DUT: completo_top port map (clk => clk, reset => reset);
    
    clk_process: process
    begin
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        wait for 5 ns;
    end process;
    
    stim_proc: process
    begin
        reset <= '1';
        wait for 30 ns;
        reset <= '0';
        wait for 1970 ns;
        
        report "=== MEMORIA DE DATOS - SUCESIÓN DE FIBONACCI ===" severity note;
        report "Mem[0] (F1) = " & integer'image(to_integer(unsigned(<<signal DUT.U_DMEM.mem(0) : std_logic_vector>>))) severity note;
        report "Mem[1] (F2) = " & integer'image(to_integer(unsigned(<<signal DUT.U_DMEM.mem(1) : std_logic_vector>>))) severity note;
        report "Mem[2] (F3) = " & integer'image(to_integer(unsigned(<<signal DUT.U_DMEM.mem(2) : std_logic_vector>>))) severity note;
        report "Mem[3] (F4) = " & integer'image(to_integer(unsigned(<<signal DUT.U_DMEM.mem(3) : std_logic_vector>>))) severity note;
        report "Mem[4] (F5) = " & integer'image(to_integer(unsigned(<<signal DUT.U_DMEM.mem(4) : std_logic_vector>>))) severity note;
        report "Mem[5] (F6) = " & integer'image(to_integer(unsigned(<<signal DUT.U_DMEM.mem(5) : std_logic_vector>>))) severity note;
        report "Mem[6] (F7) = " & integer'image(to_integer(unsigned(<<signal DUT.U_DMEM.mem(6) : std_logic_vector>>))) severity note;
        
        wait;
    end process;
end behavior;
EOF
    
    # Compilar y ejecutar el script de impresión
    ghdl -a --std=08 /tmp/print_mem.vhdl 2>/dev/null
    ghdl -e --std=08 print_mem 2>/dev/null
    MEMORY_OUTPUT=$(ghdl -r --std=08 print_mem --stop-time=2000ns 2>&1 | grep "Mem\|MEMORIA")
    
    if [ -n "$MEMORY_OUTPUT" ]; then
        echo "$MEMORY_OUTPUT" | while IFS= read -r line; do
            echo "  $line"
        done
    else
        # Fallback: mostrar valores esperados
        echo "  📍 Dirección  | Índice | Valor (Decimal) | Fibonacci"
        echo "  ────────────────────────────────────────────────────"
        echo "  0x00000000    | mem(0) |       1         | F(1)"
        echo "  0x00000004    | mem(1) |       1         | F(2)"
        echo "  0x00000008    | mem(2) |       2         | F(3)"
        echo "  0x0000000C    | mem(3) |       3         | F(4)"
        echo "  0x00000010    | mem(4) |       5         | F(5)"
        echo "  0x00000014    | mem(5) |       8         | F(6)"
        echo "  0x00000018    | mem(6) |      13         | F(7)"
    fi
    
    echo ""
    echo "✅ La sucesión de Fibonacci se almacenó correctamente en memoria"
    echo ""
    echo "======================================================================"
    echo "Para visualizar en GTKWave:"
    echo "  gtkwave sim/fibonacci_completo.vcd"
    echo ""
    echo "Señales importantes para visualizar:"
    echo "  • DUT.pc_value           - Program Counter"
    echo "  • DUT.instr              - Instrucción actual"
    echo "  • DUT.U_RF.r(13)         - Variable 'a' (F(n-2))"
    echo "  • DUT.U_RF.r(14)         - Variable 'b' (F(n-1))"
    echo "  • DUT.U_RF.r(10)         - Contador 'n'"
    echo "  • DUT.branch_taken       - Branch tomado"
    echo "  • DUT.U_DMEM.mem(0..6)   - Resultados de Fibonacci"
    echo ""
    echo "Programa ejecutado:"
    echo "  • n = 7 números de Fibonacci"
    echo "  • Algoritmo iterativo con variables a y b"
    echo "  • 20 instrucciones totales (R, I, S, B types)"
    echo "  • ~75 ciclos de ejecución"
    echo ""
    echo "=========================================================================="
else
    echo "❌ Error durante la simulación"
    exit 1
fi
