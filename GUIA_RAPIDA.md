# 🚀 Guía Rápida - AgroLabor GIS

## ⚡ Inicio Rápido (3 pasos)

### 1️⃣ Configurar Supabase

**Editar `config.js`:**
```javascript
const SUPABASE_CONFIG = {
    url: 'https://tu-proyecto.supabase.co',     // ← Tu URL aquí
    anonKey: 'eyJhbGciOiJIUzI1NiIs...',         // ← Tu Key aquí
    options: { ... }  // ← No modificar
};
```

**¿Dónde encontrar estas credenciales?**
1. Ve a tu proyecto en [Supabase](https://supabase.com)
2. Settings → API
3. Copia **Project URL** y **anon public key**

### 2️⃣ Ejecutar SQL

En Supabase → SQL Editor, ejecutar `supabase_schema_gis.sql` completo.

### 3️⃣ Abrir Aplicación

Abrir `agrolabor_gis_completo.html` en el navegador.

---

## 👤 Sistema de Autenticación

### Primer Uso - Crear Cuenta

1. Abrir la aplicación
2. Hacer clic en **"Registrarse"**
3. Completar:
   - Nombre completo
   - Email
   - Contraseña (mínimo 6 caracteres)
   - Confirmar contraseña
4. Clic en **"Crear Cuenta"**
5. **IMPORTANTE**: Revisar tu email y confirmar la cuenta
6. Volver a la aplicación e iniciar sesión

### Iniciar Sesión

1. Abrir la aplicación
2. Pestaña **"Iniciar Sesión"**
3. Ingresar email y contraseña
4. Clic en **"Iniciar Sesión"**
5. ¡Listo! Ya puedes usar el sistema

### Cerrar Sesión

- Clic en **"Cerrar Sesión"** en la esquina superior derecha
- Confirmar en el diálogo

---

## ✅ Verificación

### Todo está bien si:
- ✓ Ves la pantalla de Login/Registro
- ✓ Puedes crear una cuenta
- ✓ Recibes email de confirmación
- ✓ Después de login, ves el mapa satelital
- ✓ Estado muestra **"Conectado"** (verde)
- ✓ Puedes acceder a todas las pestañas

### Problemas comunes:

#### "No se encontró config.js"
- ✓ El archivo `config.js` debe estar en la **misma carpeta** que el HTML

#### "Configura config.js"
- ✓ Verifica que reemplazaste `tu-proyecto` y `tu-anon-key` con tus credenciales reales

#### "Error de conexión"
- ✓ Verifica credenciales en config.js
- ✓ Verifica que ejecutaste el SQL
- ✓ Verifica que PostGIS está instalado

#### El mapa no se ve
- ✓ Debes iniciar sesión primero
- ✓ Verifica conexión a internet
- ✓ Espera unos segundos a que carguen las tiles

#### No puedo crear cuenta
- ✓ Verifica que el email sea válido
- ✓ Verifica que la contraseña tenga al menos 6 caracteres
- ✓ Revisa que confirmaste el email

---

## 🗺️ Uso del Mapa

### Después de iniciar sesión:

**1. Crear una Finca**
- Pestaña **"🏡 Fincas"**
- Llenar nombre y ubicación
- Clic en "Agregar Finca"

**2. Crear Cuarteles**
- Pestaña **"🗺️ Mapa"**
- Seleccionar la finca
- Hacer clic en **"📐 Polígono"** o **"⬛ Rectángulo"**
- Dibujar en el mapa
- Completar datos (nombre, cultivo, variedad opcional)
- Guardar

**3. Ver GPS**
- Clic en **"📍 Mi Ubicación"**
- Permitir acceso a ubicación
- El mapa se centra en tu posición

**4. Importar Archivos**
- En pestaña **"🗺️ Mapa"**
- Sección "Importar Archivo"
- Seleccionar finca destino
- Arrastrar archivo (.kml, .geojson, .shp.zip)
- Confirmar importación

**5. Filtrar Vista**
- Usar dropdown **"Colorear por"**
- Seleccionar: Cultivo, Variedad o Finca
- Usar **"Filtrar por Finca"** para mostrar solo una finca

---

## 📊 Flujo de Trabajo Típico

```
1. Registrarse/Login
   ↓
2. Crear Fincas
   ↓
3. Crear Cuarteles (dibujando o importando)
   ↓
4. Registrar Trabajadores
   ↓
5. Registrar Labores diarias
   ↓
6. Consultar reportes
   ↓
7. Exportar a Excel
```

---

## 🔐 Seguridad

### ⚠️ IMPORTANTE:

**NO compartas `config.js` públicamente**
- Contiene credenciales de tu base de datos
- Cualquiera con estas credenciales puede acceder a tus datos

**Buenas prácticas:**
- ✓ Usa contraseñas fuertes
- ✓ No compartas tu cuenta
- ✓ Cierra sesión en computadoras públicas
- ✓ Habilita RLS (Row Level Security) en Supabase para mayor seguridad

### Habilitar RLS (Recomendado):

En Supabase SQL Editor:
```sql
ALTER TABLE fincas ENABLE ROW LEVEL SECURITY;
ALTER TABLE cuarteles ENABLE ROW LEVEL SECURITY;
ALTER TABLE trabajadores ENABLE ROW LEVEL SECURITY;
ALTER TABLE registros_horas ENABLE ROW LEVEL SECURITY;

-- Política: usuarios solo ven sus propios datos
CREATE POLICY "Usuarios ven solo sus datos" ON fincas
    FOR ALL USING (auth.uid() = user_id);
```

---

## 📱 Dispositivos

### Desktop (Recomendado)
- Experiencia completa
- Todas las funcionalidades

### Tablet
- Funciona bien
- Pantalla táctil para dibujar

### Móvil
- Funcional
- Mejor para consultar que para crear

---

## 🆘 Ayuda Rápida

### No puedo dibujar en el mapa
- ✓ Selecciona una finca primero
- ✓ Haz clic en "📐 Polígono" o "⬛ Rectángulo"
- ✓ Luego haz clic en el mapa para empezar a dibujar

### Los cuarteles no aparecen
- ✓ Espera a que cargue la página
- ✓ Haz clic en "🔍 Ajustar Vista"
- ✓ Verifica que los guardaste correctamente

### No veo mis fincas/trabajadores
- ✓ Verifica que iniciaste sesión
- ✓ Verifica que los creaste en la sesión actual
- ✓ Recarga la página (F5)

---

## 📞 Soporte Técnico

**Consola del navegador (F12):**
- Ver errores en la pestaña "Console"
- Ayuda a identificar problemas

**Verificar conexión:**
- Estado en esquina inferior derecha
- Verde = Conectado
- Rojo = Desconectado

**Logs útiles:**
```
✓ Aplicación cargada
✓ Supabase inicializado correctamente
✓ Mapa inicializado correctamente
✓ Conectado a Supabase exitosamente
```

---

## 📋 Checklist

Antes de empezar:
- [ ] config.js configurado con credenciales reales
- [ ] SQL ejecutado en Supabase
- [ ] PostGIS instalado
- [ ] Cuenta creada y email confirmado
- [ ] Sesión iniciada
- [ ] Mapa satelital visible
- [ ] Estado "Conectado" (verde)
- [ ] Primera finca creada

---

**¡Ya estás listo para usar AgroLabor GIS!** 🌾🗺️
