# Método Simplificado para Generar Diagrama en Active-HDL

## 🎯 MÉTODO MANUAL PASO A PASO (100% FUNCIONAL)

Active-HDL requiere que crees el diagrama manualmente. Aquí está el proceso exacto:

---

### **Paso 1: Verificar Compilación**

1. Abre Active-HDL
2. Ve a: **Design → Compile → Compile All**
3. Verifica en la consola que aparezca:
   ```
   Compile success 0 Errors 0 Warnings
   ```

---

### **Paso 2: Crear Block Diagram Vacío**

1. Ve a: **File → New → Block Diagram**

2. Aparecerá un diálogo "New Block Diagram":
   - **Name:** `riscv_diagram`
   - **Location:** (deja el default o elige tu carpeta)
   - Click **OK**

3. Se abrirá un canvas vacío (workspace del diagrama)

---

### **Paso 3: Agregar el Procesador al Diagrama**

1. **Abre la ventana Design Browser** (si no está visible):
   ```
   View → Design Browser
   ```

2. **En Design Browser, navega a:**
   ```
   Libraries
   └── work
       └── riscv_processor_top (entity)
   ```

3. **ARRASTRA** `riscv_processor_top` al canvas del Block Diagram
   - Click y mantén sobre `riscv_processor_top`
   - Arrastra al canvas
   - Suelta

4. Verás aparecer un rectángulo con:
   ```
   ┌─────────────────────────────┐
   │  riscv_processor_top        │
   │                             │
   │  clk          ┤             │
   │  reset        ┤             │
   │               ├  pc_out     │
   │               ├  instr_out  │
   │               ├  alu_res_out│
   │               ├  reg_we_out │
   │               ├  mem_we_out │
   │               ├  branch_out │
   └─────────────────────────────┘
   ```

---

### **Paso 4: Ver Componentes Internos (Opcional)**

Para ver los componentes internos (PC, ALU, Decoder, etc.):

1. **Click derecho** sobre el símbolo `riscv_processor_top`

2. Busca una opción llamada:
   - **"Push into Hierarchy"** o
   - **"Descend into Hierarchy"** o
   - **"Open Architecture"**

3. Click en esa opción

4. Verás los componentes internos:
   ```
   U_PC (program_counter)
   U_IMEM (instruction_memory_fibonacci)
   U_DECODER (decoder)
   U_REGFILE (BancoDeRegistros)
   U_IMMEXT (ImmExtend)
   U_ALU (ALU)
   U_DMEM (data_mem_simple)
   ```

---

### **Paso 5: Personalizar el Diagrama (Opcional)**

- **Mover componentes:** Click y arrastra
- **Agregar texto:** Insert → Text
- **Agregar formas:** Insert → Shape
- **Zoom:** Ctrl + rueda del mouse
- **Auto-organizar:** Edit → Auto Layout (si está disponible)

---

### **Paso 6: Guardar**

```
File → Save
```

El archivo se guardará como: `riscv_diagram.bde`

---

## 🔧 SOLUCIÓN ALTERNATIVA: Structure Window

Si el método anterior no funciona, usa **Structure Window**:

### Pasos:

1. **Click derecho** en `riscv_processor_top` (en Design Browser)

2. Selecciona: **"Open Structure"** o **"Structure Window"**

3. Verás una vista de árbol:
   ```
   ▼ riscv_processor_top
     ├─ U_PC : program_counter
     ├─ U_IMEM : instruction_memory_fibonacci
     ├─ U_DECODER : decoder
     ├─ U_REGFILE : BancoDeRegistros
     ├─ U_IMMEXT : ImmExtend
     ├─ U_ALU : ALU
     └─ U_DMEM : data_mem_simple
   ```

4. **Para ver conexiones:**
   - Click derecho en cualquier componente
   - **Show Connections** o **Trace Net**

---

## 🎨 SOLUCIÓN ALTERNATIVA 2: RTL Viewer

### Pasos:

1. En **Design Browser**, selecciona `riscv_processor_top`

2. **Click derecho** → busca:
   - **"View RTL"** o
   - **"RTL Viewer"** o
   - En el menú: **Tools → RTL Viewer**

3. Si está disponible, generará automáticamente un diagrama esquemático completo

---

## 📸 Exportar el Diagrama

Una vez tengas el diagrama visible:

```
File → Export → Select format:
  - PDF (para documentos)
  - PNG (para presentaciones)
  - SVG (para edición)
```

O:

```
File → Print → Microsoft Print to PDF
```

---

## ⚠️ Si Nada Funciona

Es posible que tu versión de Active-HDL sea:
- **Student Edition** (funcionalidad limitada)
- **Versión antigua** (sin soporte para diagramas)
- **Sin licencia de síntesis** (solo simulación)

### En ese caso:

**Opción 1: Usar el Testbench**

El testbench ya muestra el funcionamiento del procesador:

```bash
# Compilar
Design → Compile → Compile All

# Simular
Click derecho en fibonacci_processor_tb → Set as Top Level
Simulation → Initialize Simulation
Simulation → Run → Run for 2000ns
```

**Opción 2: Generar diagrama manualmente**

Usa una herramienta externa como:
- Draw.io (https://draw.io)
- Lucidchart
- Microsoft Visio
- Inkscape

He creado una plantilla ASCII del diagrama en el archivo `GENERAR_DIAGRAMA_ACTIVE_HDL.md`

---

## ✅ Checklist de Verificación

Antes de crear el diagrama:

- [ ] Todos los archivos .vhdl compilados sin errores
- [ ] `riscv_processor_top` visible en biblioteca `work`
- [ ] Design Browser abierto y visible
- [ ] No hay errores de sintaxis en ningún archivo

---

## 🆘 Errores Comunes

### Error: "Cannot find riscv_processor_top"

**Solución:**
```
1. Design → Compile → Compile riscv_processor_top.vhdl
2. View → Refresh
3. Busca en: Libraries → work
```

### Error: "Access denied" o "Cannot create file"

**Solución:**
```
1. Cierra Active-HDL
2. Click derecho en Active-HDL → Run as Administrator
3. Intenta de nuevo
```

### Error: El diagrama está vacío

**Solución:**
```
1. Asegúrate de arrastrar desde Design Browser
2. No desde el explorador de archivos
3. Debe ser desde Libraries → work → riscv_processor_top
```

---

## 💡 Tip Final

**La forma más confiable de visualizar el diseño en Active-HDL es:**

1. **Simular el testbench** (fibonacci_processor_tb)
2. **Ver las señales** en el Wave Viewer
3. **Usar Structure Window** para navegar componentes

Esto funciona en TODAS las versiones de Active-HDL.
