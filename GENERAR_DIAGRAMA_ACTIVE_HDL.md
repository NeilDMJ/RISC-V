# Cómo Generar el Diagrama de Bloques en Active-HDL

## ⚠️ Problema Común
Active-HDL no siempre muestra la opción "Generate Block Diagram" directamente. Aquí están las soluciones que **SÍ funcionan**.

---

## ✅ Solución 1: Crear Block Diagram Manualmente (MÁS FÁCIL)

### Pasos:

1. **Asegúrate de que el diseño está compilado:**
   ```
   Design → Compile → Compile All
   ```
   Verifica que no haya errores (0 errors en la consola)

2. **Crear nuevo Block Diagram:**
   ```
   File → New → Block Diagram
   ```

3. **Nombre del diagrama:**
   ```
   riscv_processor_visual
   ```
   Click **OK**

4. **Agregar el componente top:**
   - En la ventana **Design Browser** (panel izquierdo)
   - Expande la biblioteca `work`
   - Busca `riscv_processor_top`
   - **ARRASTRA** el componente al canvas del Block Diagram

5. **Active-HDL mostrará automáticamente:**
   - Todos los puertos (clk, reset, pc_out, etc.)
   - El símbolo del componente

6. **Ver la jerarquía interna:**
   - Click derecho en el componente → **Push into Hierarchy**
   - Verás todos los componentes internos (PC, ALU, Decoder, etc.)

7. **Guardar:**
   ```
   File → Save
   ```

---

## ✅ Solución 2: Structure Viewer (VER JERARQUÍA)

### Pasos:

1. **Compilar el diseño**

2. **Abrir Structure Viewer:**
   ```
   Click derecho en 'riscv_processor_top' → Open Structure
   ```
   O:
   ```
   View → Structure
   ```

3. **Verás un árbol jerárquico con:**
   ```
   riscv_processor_top
   ├── U_PC (program_counter)
   ├── U_IMEM (instruction_memory_fibonacci)
   ├── U_DECODER (decoder)
   ├── U_REGFILE (BancoDeRegistros)
   ├── U_IMMEXT (ImmExtend)
   ├── U_ALU (ALU)
   └── U_DMEM (data_mem_simple)
   ```

4. **Para ver conexiones:**
   - Click derecho en cualquier componente → **Show Connections**

---

## ✅ Solución 3: RTL Viewer (VISTA ESQUEMÁTICA)

### Pasos:

1. **Compilar el diseño**

2. **Seleccionar el top-level:**
   - En Design Browser, click en `riscv_processor_top`

3. **Abrir RTL Viewer:**
   ```
   Click derecho → View RTL
   ```
   O:
   ```
   Tools → RTL Viewer
   ```

4. **Active-HDL generará automáticamente:**
   - Un diagrama esquemático completo
   - Todas las interconexiones
   - Puedes hacer zoom, exportar a PDF/PNG

---

## ✅ Solución 4: Script TCL Automático

### Si tienes acceso a la consola TCL:

1. **Ejecutar el script:**
   ```
   Tools → Execute Macro → Seleccionar 'scripts/generate_diagram.tcl'
   ```

2. **El script creará automáticamente:**
   - Un nuevo Block Diagram
   - Con el procesador expandido

3. **Archivo generado:**
   ```
   riscv_processor_diagram.bde
   ```

---

## ✅ Solución 5: Generar Símbolo Personalizado

### Para crear un símbolo reutilizable:

1. **Click derecho en `riscv_processor_top`**

2. **Seleccionar:** `Generate Symbol`

3. **Configurar:**
   - Port Arrangement: Left/Right/Top/Bottom
   - Symbol Shape: Rectangle

4. **El símbolo se guardará en:** `work/riscv_processor_top.asf`

5. **Ahora puedes:**
   - Arrastrar el símbolo a cualquier Block Diagram
   - Usarlo como componente en otros diseños

---

## 📊 Qué Verás en el Diagrama

```
┌─────────────────────────────────────────────────────────┐
│              RISCV_PROCESSOR_TOP                        │
│                                                          │
│  clk ──────┬─────────────────────────────────────┐     │
│  reset ────┼─────────┐                            │     │
│            │         │                            │     │
│      ┌─────▼────┐    │                            │     │
│      │   PC     │    │  (program_counter)         │     │
│      │ U_PC     │    │                            │     │
│      └─────┬────┘    │                            │     │
│            │         │                            │     │
│      pc_current      │                            │     │
│            │         │                            │     │
│            ▼         │                            │     │
│      ┌──────────┐    │                            │     │
│      │  IMEM    │    │  (instruction_memory)      │     │
│      │ U_IMEM   │    │                            │     │
│      └─────┬────┘    │                            │     │
│            │         │                            │     │
│      instruction     │                            │     │
│            │         ▼                            │     │
│            │   ┌──────────┐                       │     │
│            ├──►│ DECODER  │  (control_unit)       │     │
│            │   │ U_DECODER│                       │     │
│            │   └────┬─────┘                       │     │
│            │        │ ctrl signals                │     │
│            │        │                             │     │
│            ▼        ▼                             │     │
│      ┌──────────────────┐                         │     │
│      │    REGFILE       │  (register_file)        │     │
│      │   U_REGFILE      │                         │     │
│      └────┬────────┬────┘                         │     │
│           │        │                              │     │
│      do1  │        │ do2                          │     │
│           │        │                              │     │
│           ▼        │                              │     │
│      ┌─────────┐   │                              │     │
│      │ IMMEXT  │   │  (immediate_extend)          │     │
│      │U_IMMEXT │   │                              │     │
│      └────┬────┘   │                              │     │
│           │        │                              │     │
│      imm_ext       │                              │     │
│           │        │                              │     │
│           ▼        ▼                              │     │
│      ┌─────────────────────┐                      │     │
│      │        ALU          │                      │     │
│      │       U_ALU         │                      │     │
│      └──────────┬──────────┘                      │     │
│                 │                                 │     │
│           alu_result                              │     │
│                 │                                 │     │
│                 ▼                                 │     │
│           ┌──────────┐                            │     │
│           │   DMEM   │  (data_memory)             │     │
│           │  U_DMEM  │                            │     │
│           └──────────┘                            │     │
│                                                    │     │
│  Outputs: pc_out, instr_out, alu_res_out         │     │
│           reg_we_out, mem_we_out, branch_out     │     │
└─────────────────────────────────────────────────────────┘
```

---

## 🔧 Solución de Problemas

### ❌ "No puedo encontrar el componente en Design Browser"

**Solución:**
```
1. Design → Compile → Compile All
2. Verifica que dice "0 errors" en la consola
3. Refresca Design Browser: View → Refresh
```

### ❌ "El símbolo no muestra los componentes internos"

**Solución:**
```
1. Click derecho en el componente
2. Selecciona "Push into Hierarchy"
3. O usa Structure Viewer
```

### ❌ "Active-HDL se cierra o da error"

**Solución:**
```
1. Verifica la versión de Active-HDL
2. Algunas versiones antiguas tienen bugs
3. Usa Structure Viewer en su lugar
```

### ❌ "Quiero exportar el diagrama a PDF/PNG"

**Solución:**
```
1. Con el diagrama abierto
2. File → Export → Choose format (PDF, PNG, SVG)
3. O: Tools → Print to PDF
```

---

## 📝 Checklist de Verificación

Antes de intentar generar el diagrama:

- [ ] ✅ Todos los archivos .vhdl están agregados al proyecto
- [ ] ✅ Compilación exitosa (0 errors)
- [ ] ✅ `riscv_processor_top` aparece en biblioteca `work`
- [ ] ✅ La arquitectura es `structural` (no `behavioral`)
- [ ] ✅ Design Browser está visible (View → Design Browser)

---

## 🎯 Método Recomendado

**Para Active-HDL versiones recientes:**
1. Usa **RTL Viewer** (Solución 3)
   - Es automático
   - Muestra todo el diseño
   - Exportable a PDF

**Para versiones antiguas:**
1. Usa **Block Diagram Manual** (Solución 1)
   - Control total
   - Puedes personalizar el layout
   - Fácil de documentar

**Para debugging:**
1. Usa **Structure Viewer** (Solución 2)
   - Ver jerarquía
   - Navegar componentes
   - Ver conexiones

---

## 📚 Referencias Adicionales

- Active-HDL User Guide: Block Diagram Editor
- Active-HDL User Guide: Structure Viewer
- Active-HDL User Guide: RTL Viewer

---

## 💡 Nota Final

Si ninguna de estas soluciones funciona, es posible que tu versión de Active-HDL:
- No tenga licencia completa para síntesis/visualización
- Sea una versión Student/Limited
- Requiera activar módulos adicionales

En ese caso, puedes:
1. Usar la simulación para verificar el funcionamiento
2. Usar herramientas externas como Graphviz para generar el diagrama
3. Crear el diagrama manualmente en otra herramienta (Visio, Draw.io)
