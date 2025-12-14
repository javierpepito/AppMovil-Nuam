# 🧪 GUÍA DE PRUEBAS - App Móvil NUAM

## ✅ Estado del Proyecto

- ✅ Código analizado sin errores críticos
- ✅ Dependencias instaladas correctamente
- ✅ Todos los endpoints implementados
- ✅ Todas las pantallas creadas
- ✅ Navegación configurada

---

## 🚀 Pasos para Ejecutar

### 1. Asegúrate que Django esté corriendo

```bash
# En tu proyecto Django
python manage.py runserver
```

Debe estar en `http://localhost:8000`

### 2. Verifica la configuración de la app

Archivo: `lib/config/api_config.dart`
```dart
static const bool isDevelopment = true;
static const String devBaseUrl = 'http://localhost:8000';
```

### 3. Ejecuta la app

```bash
cd d:\AppMovil-Nuam\app_movil_nuam
flutter run
```

O desde VS Code: Presiona `F5`

---

## 📝 Script de Pruebas

### Test 1: Login ✅

**Objetivo**: Verificar autenticación de jefe

**Pasos**:
1. Abre la app
2. Debes ver la pantalla de login con:
   - Campo RUT
   - Campo Contraseña
   - Botón "Iniciar Sesión"
   - Mensaje: "Solo Jefes de Equipo pueden acceder"
3. Ingresa RUT de un jefe (ej: `12345678-9`)
4. Ingresa contraseña
5. Presiona "Iniciar Sesión"

**Resultado esperado**:
- ✅ Si las credenciales son correctas → Navega a pantalla Home
- ❌ Si son incorrectas → Muestra mensaje de error en rojo
- ✅ La sesión se guarda (al cerrar y abrir la app, va directo al Home)

---

### Test 2: Dashboard ✅

**Objetivo**: Verificar estadísticas y lista de pendientes

**Pasos**:
1. En la pantalla de Inicio, verifica que se muestre:
   - Saludo con tu nombre
   - Nombre del equipo
   - 6 tarjetas de estadísticas:
     - Pendientes
     - Aprobadas Hoy
     - Rechazadas Hoy
     - Alto Riesgo
     - Promedio Puntaje
     - % Aprobación
   - Lista de calificaciones pendientes

**Resultado esperado**:
- ✅ Tarjetas muestran números correctos
- ✅ Lista muestra todas las calificaciones pendientes
- ✅ Cada card muestra:
  - Nombre de empresa
  - RUT
  - Puntaje
  - Categoría
  - Nivel de riesgo (con color)
  - Calificador
  - Fecha

---

### Test 3: Detalle y Aprobar ✅

**Objetivo**: Aprobar una calificación

**Pasos**:
1. En la lista de pendientes, toca una calificación
2. Verifica que se abra el detalle con toda la info
3. Presiona el botón verde "Aprobar"
4. Ingresa observaciones (ej: "Datos correctos, aprobado")
5. Presiona "Aprobar" en el diálogo

**Resultado esperado**:
- ✅ Muestra mensaje: "Calificación aprobada exitosamente"
- ✅ Vuelve a la lista de pendientes
- ✅ La calificación ya no aparece en pendientes
- ✅ El contador de pendientes se reduce en 1

---

### Test 4: Detalle y Rechazar ✅

**Objetivo**: Rechazar una calificación

**Pasos**:
1. En la lista de pendientes, toca otra calificación
2. Presiona el botón rojo "Rechazar"
3. Ingresa observaciones (ej: "Revisar monto tributario")
4. Presiona "Rechazar" en el diálogo

**Resultado esperado**:
- ✅ Muestra mensaje: "Calificación rechazada"
- ✅ Vuelve a la lista
- ✅ La calificación desaparece de pendientes

---

### Test 5: Historial - Aprobadas ✅

**Objetivo**: Ver calificaciones aprobadas

**Pasos**:
1. Toca la tab "Historial" en el navbar inferior
2. Verifica que estés en el tab "Aprobadas"
3. Revisa la lista

**Resultado esperado**:
- ✅ Muestra todas las calificaciones aprobadas
- ✅ Cada card tiene icono verde de check
- ✅ Muestra observaciones del jefe
- ✅ Muestra fecha de revisión

---

### Test 6: Historial - Rechazadas ✅

**Objetivo**: Ver calificaciones rechazadas

**Pasos**:
1. En Historial, cambia al tab "Rechazadas"
2. Revisa la lista

**Resultado esperado**:
- ✅ Muestra todas las calificaciones rechazadas
- ✅ Cada card tiene icono rojo de cancel
- ✅ Muestra observaciones del jefe
- ✅ Muestra fecha de revisión

---

### Test 7: Mi Equipo ✅

**Objetivo**: Ver miembros del equipo

**Pasos**:
1. Toca la tab "Equipo" en el navbar
2. Verifica la información

**Resultado esperado**:
- ✅ Muestra card con nombre del equipo
- ✅ Muestra total de miembros
- ✅ Lista todos los calificadores
- ✅ Cada miembro muestra:
  - Avatar con iniciales
  - Nombre completo
  - RUT
  - Correo
  - Teléfono
  - Estadísticas: Total, Pendientes, Aprobadas, Rechazadas

---

### Test 8: Ver Perfil ✅

**Objetivo**: Ver datos del perfil

**Pasos**:
1. Toca la tab "Perfil" en el navbar
2. Revisa la información

**Resultado esperado**:
- ✅ Muestra avatar con iniciales
- ✅ Muestra nombre completo
- ✅ Badge "Jefe de Equipo"
- ✅ Card "Información Personal":
  - RUT
  - Correo
  - Teléfono
  - Dirección (si existe)
  - Edad (si existe)
- ✅ Card "Equipo":
  - Nombre del equipo
  - ID del equipo
- ✅ Botón rojo "Cerrar Sesión"

---

### Test 9: Editar Perfil ✅

**Objetivo**: Actualizar datos personales

**Pasos**:
1. En Perfil, toca el icono de editar (arriba a la derecha)
2. Modifica el teléfono (ej: `+56999888777`)
3. Modifica el correo (ej: `nuevo@correo.com`)
4. Presiona "Guardar Cambios"

**Resultado esperado**:
- ✅ Muestra mensaje: "Perfil actualizado exitosamente"
- ✅ Los datos se actualizan en la pantalla
- ✅ Al cerrar y abrir la app, los datos persisten

---

### Test 10: Cerrar Sesión ✅

**Objetivo**: Salir de la app

**Pasos**:
1. En Perfil, presiona "Cerrar Sesión"
2. Confirma en el diálogo

**Resultado esperado**:
- ✅ Vuelve a la pantalla de login
- ✅ La sesión se borra
- ✅ Al abrir la app de nuevo, pide login

---

### Test 11: Sesión Persistente ✅

**Objetivo**: Verificar que la sesión se mantenga

**Pasos**:
1. Haz login
2. Navega por la app
3. Cierra completamente la app (forzar cierre)
4. Abre la app de nuevo

**Resultado esperado**:
- ✅ No pide login
- ✅ Va directo al Home
- ✅ Los datos del usuario persisten

---

### Test 12: Pull to Refresh ✅

**Objetivo**: Recargar datos

**Pasos**:
1. En cualquier pantalla (Inicio, Historial, Equipo)
2. Desliza hacia abajo para refrescar

**Resultado esperado**:
- ✅ Muestra indicador de carga
- ✅ Recarga los datos desde la API
- ✅ Actualiza la interfaz

---

### Test 13: Manejo de Errores ✅

**Objetivo**: Ver cómo la app maneja errores

**Pasos**:
1. Detén el servidor Django
2. Intenta hacer login
3. O intenta refrescar datos

**Resultado esperado**:
- ✅ Muestra mensaje de error
- ✅ No se cuelga la app
- ✅ Permite reintentar

---

## 🐛 Checklist de Errores Comunes

### ❌ Error: "No se pudo conectar a la API"

**Soluciones**:
- ✅ Verifica que Django esté corriendo en `http://localhost:8000`
- ✅ En Android: Usa `http://10.0.2.2:8000` (emulador) o tu IP local
- ✅ Revisa `lib/config/api_config.dart`

### ❌ Error: "Login failed"

**Soluciones**:
- ✅ Verifica que el usuario sea Jefe de Equipo en Django
- ✅ Verifica RUT y contraseña
- ✅ Revisa logs del backend Django

### ❌ Error: "No hay calificaciones pendientes"

**Soluciones**:
- ✅ Crea calificaciones pendientes desde Django admin
- ✅ Asigna calificaciones al equipo del jefe
- ✅ Verifica el estado sea "por_aprobar"

### ❌ App se queda en "Cargando..."

**Soluciones**:
- ✅ Cierra y abre la app
- ✅ Limpia datos: `flutter clean && flutter pub get`
- ✅ Borra datos de la app en el dispositivo

---

## 📊 Checklist Final

Antes de considerar la app lista para producción:

- [ ] Todos los tests pasan ✅
- [ ] Login funciona correctamente
- [ ] Dashboard muestra datos reales
- [ ] Aprobar/Rechazar funciona
- [ ] Historial se actualiza correctamente
- [ ] Ver equipo funciona
- [ ] Editar perfil funciona
- [ ] Cerrar sesión funciona
- [ ] Sesión persistente funciona
- [ ] Pull to refresh funciona
- [ ] Manejo de errores es adecuado
- [ ] Interfaz es responsive
- [ ] Colores y diseño son correctos

---

## 🚀 Compilación para Producción

### Android (APK)

```bash
flutter build apk --release
```

APK generado en: `build/app/outputs/flutter-apk/app-release.apk`

### Android (App Bundle - Google Play)

```bash
flutter build appbundle --release
```

AAB generado en: `build/app/outputs/bundle/release/app-release.aab`

### iOS

```bash
flutter build ios --release
```

---

## 📝 Notas Finales

1. **Base URL**: Cambia `isDevelopment = false` en producción
2. **Seguridad**: Implementa JWT o tokens en producción
3. **HTTPS**: Usa HTTPS en producción
4. **Validaciones**: El backend debe validar permisos
5. **Logs**: Los `print()` se deben eliminar en producción

---

**¡La app está lista para probar! 🎉**
