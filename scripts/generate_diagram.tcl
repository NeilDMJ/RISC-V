# Script TCL para generar diagrama de bloques en Active-HDL
# Ejecutar en: Tools → Execute Macro → Seleccionar este archivo

puts "Iniciando generación de diagrama..."

# Configurar variables
set diagram_name "riscv_processor_diagram"
set diagram_file "${diagram_name}.bde"

# Crear nuevo Block Diagram con sintaxis correcta
puts "Creando Block Diagram: $diagram_file"
createdesign $diagram_file [pwd]

# Verificar si se creó
if {[file exists $diagram_file]} {
    puts "Block Diagram creado exitosamente"
    
    # Abrir el diagrama
    puts "Abriendo diagrama..."
    opendesign $diagram_file
    
    puts "Diagrama generado. Ahora puedes:"
    puts "1. Ir a Design Browser"
    puts "2. Arrastrar 'riscv_processor_top' desde la biblioteca 'work'"
    puts "3. Click derecho → Push into Hierarchy para ver componentes internos"
} else {
    puts "Error: No se pudo crear el Block Diagram"
    puts "Usa el método manual:"
    puts "File → New → Block Diagram"
}

puts "Script completado."
