# Debugging: Aprobadas/Rechazadas del Día Muestran 0

## Problema
El dashboard muestra **0** en "Aprobadas Hoy" y "Rechazadas Hoy" incluso después de aprobar/rechazar calificaciones.

## Causas Posibles

### 1. **Problema de Zona Horaria**
El backend podría estar usando una zona horaria diferente para calcular "hoy".

**Solución en Django (`views.py`, DashboardAPIView):**

```python
from django.utils import timezone
from datetime import datetime, time

# ANTES (puede estar usando fecha UTC en lugar de zona horaria local)
hoy = timezone.now().date()

# DESPUÉS (asegurar zona horaria correcta)
# En settings.py verificar:
# TIME_ZONE = 'America/Santiago'  # Para Chile
# USE_TZ = True

# En views.py:
hoy = timezone.localtime(timezone.now()).date()
hoy_inicio = timezone.make_aware(datetime.combine(hoy, time.min))
hoy_fin = timezone.make_aware(datetime.combine(hoy, time.max))

# Contar aprobadas hoy
total_aprobadas_hoy = CalificacionAprovada.objects.filter(
    calificacion__cuenta_id__equipo_trabajo=jefe.equipo_trabajo,
    fecha_aprovacion__range=[hoy_inicio, hoy_fin]
).count()

# Contar rechazadas hoy
total_rechazadas_hoy = CalificacionRechazada.objects.filter(
    calificacion__cuenta_id__equipo_trabajo=jefe.equipo_trabajo,
    fecha_rechazo__range=[hoy_inicio, hoy_fin]
).count()
```

### 2. **Nombres de Campos Incorrectos**
Verificar que los nombres de los campos de fecha sean correctos.

**Revisar en `models.py`:**
- ¿El campo en `CalificacionAprovada` se llama `fecha_aprovacion` o `fecha_aprobacion`?
- ¿El campo en `CalificacionRechazada` se llama `fecha_rechazo` o `fecha_rechazada`?

**Si hay un typo (aprovacion vs aprobacion), ajustar el query:**
```python
# Si el campo es fecha_aprobacion (con 'b'):
total_aprobadas_hoy = CalificacionAprovada.objects.filter(
    calificacion__cuenta_id__equipo_trabajo=jefe.equipo_trabajo,
    fecha_aprobacion__date=hoy  # Cambiar aquí
).count()
```

### 3. **Filtro de Equipo Incorrecto**
Verificar que se estén contando las calificaciones del equipo correcto.

**Verificar el query:**
```python
# Asegurarse de que el jefe tiene equipo
if not jefe.equipo_trabajo:
    # Manejar caso sin equipo
    total_aprobadas_hoy = 0
    total_rechazadas_hoy = 0
else:
    # Contar correctamente
    equipo_id = jefe.equipo_trabajo.equipo_id
    
    total_aprobadas_hoy = CalificacionAprovada.objects.filter(
        calificacion__cuenta_id__equipo_trabajo_id=equipo_id,
        fecha_aprovacion__date=hoy
    ).count()
```

## Cómo Depurar

### Paso 1: Verificar en Django Admin
1. Acceder al admin de Django
2. Ver la tabla `CalificacionAprovada`
3. Verificar:
   - ¿Existe el registro de aprobación?
   - ¿Qué fecha tiene el registro?
   - ¿Coincide con "hoy"?

### Paso 2: Probar Query en Django Shell
```bash
python manage.py shell
```

```python
from Contenedor_Calificaciones.models import *
from django.utils import timezone
from datetime import datetime, time

# Obtener el jefe
jefe = Cuenta.objects.get(rut='TU_RUT_JEFE')
equipo = jefe.equipo_trabajo

# Ver zona horaria
print(f"Timezone: {timezone.get_current_timezone()}")
print(f"Ahora: {timezone.now()}")
print(f"Ahora (local): {timezone.localtime(timezone.now())}")

# Calcular hoy
hoy = timezone.localtime(timezone.now()).date()
print(f"Hoy: {hoy}")

# Contar aprobadas
aprobadas_hoy = CalificacionAprovada.objects.filter(
    calificacion__cuenta_id__equipo_trabajo=equipo,
    fecha_aprovacion__date=hoy
)
print(f"Aprobadas hoy: {aprobadas_hoy.count()}")
for a in aprobadas_hoy:
    print(f"  - Fecha: {a.fecha_aprovacion}, Calificación: {a.calificacion.calificacion_id}")

# Contar rechazadas
rechazadas_hoy = CalificacionRechazada.objects.filter(
    calificacion__cuenta_id__equipo_trabajo=equipo,
    fecha_rechazo__date=hoy
)
print(f"Rechazadas hoy: {rechazadas_hoy.count()}")
for r in rechazadas_hoy:
    print(f"  - Fecha: {r.fecha_rechazo}, Calificación: {r.calificacion.calificacion_id}")
```

### Paso 3: Verificar Response de la API
En la app móvil, agregar logging temporal:

**En `api_service.dart` (getDashboardStats):**
```dart
if (response.statusCode == 200) {
  final data = jsonDecode(response.body);
  print('DEBUG - Dashboard response: $data'); // VER QUÉ VIENE
  return DashboardStats.fromJson(data);
}
```

Luego en la terminal de Flutter buscar el print y verificar los valores de:
- `total_aprobadas_hoy`
- `total_rechazadas_hoy`

## Solución Rápida (Temporal)

Si necesitas que funcione YA, puedes cambiar el cálculo a "aprobadas/rechazadas en los últimos 7 días":

```python
# En DashboardAPIView
hace_7_dias = timezone.now() - timedelta(days=7)

total_aprobadas_recientes = CalificacionAprovada.objects.filter(
    calificacion__cuenta_id__equipo_trabajo=jefe.equipo_trabajo,
    fecha_aprovacion__gte=hace_7_dias
).count()

total_rechazadas_recientes = CalificacionRechazada.objects.filter(
    calificacion__cuenta_id__equipo_trabajo=jefe.equipo_trabajo,
    fecha_rechazo__gte=hace_7_dias
).count()
```

Y cambiar en Flutter:
```dart
// En inicio_screen.dart
StatCard(
  title: 'Aprobadas (7 días)',
  value: '${_stats!.totalAprobadasHoy}',
  icon: Icons.check_circle,
  color: Colors.green,
),
```

## Checklist de Verificación

- [ ] Verificar `TIME_ZONE` en `settings.py` (debe ser 'America/Santiago' o tu zona)
- [ ] Verificar nombres de campos: `fecha_aprovacion` vs `fecha_aprobacion`
- [ ] Verificar nombres de campos: `fecha_rechazo` vs `fecha_rechazada`
- [ ] Ejecutar queries en Django shell para ver qué devuelven
- [ ] Verificar que las aprobaciones/rechazos SÍ se están guardando en la BD
- [ ] Revisar el código actual de `DashboardAPIView` línea por línea
- [ ] Agregar logging temporal en Flutter para ver qué responde la API

---
**Fecha:** 16 de diciembre de 2025
