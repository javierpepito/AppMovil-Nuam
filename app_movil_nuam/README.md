# App Móvil NUAM - Jefe de Equipo

Aplicación móvil Flutter para que el Jefe de Equipo pueda gestionar calificaciones tributarias.

## 🚀 Características

- ✅ **Login**: Autenticación exclusiva para Jefes de Equipo con sesión persistente
- 📊 **Dashboard**: Estadísticas en tiempo real del equipo
- 📋 **Calificaciones Pendientes**: Lista de calificaciones por aprobar/rechazar
- 📜 **Historial**: Ver calificaciones aprobadas y rechazadas
- 👥 **Mi Equipo**: Visualizar miembros y sus estadísticas
- 👤 **Perfil**: Editar datos personales y cerrar sesión

## 📱 Navegación

La app cuenta con un `BottomNavigationBar` con 4 secciones:

1. **Inicio** 🏠: Dashboard + Lista de pendientes
2. **Historial** 📜: Tabs de aprobadas y rechazadas
3. **Equipo** 👥: Miembros del equipo
4. **Perfil** 👤: Datos personales y cerrar sesión

## 🔧 Configuración

### API Backend (Django)

Edita el archivo `lib/config/api_config.dart`:

```dart
static const bool isDevelopment = true; // Cambiar a false en producción
static const String devBaseUrl = 'http://localhost:8000';
static const String prodBaseUrl = 'https://tu-dominio.com';
```

### Ejecutar la app

```bash
# Obtener dependencias
flutter pub get

# Ejecutar en modo desarrollo
flutter run

# Compilar para producción
flutter build apk --release  # Android
flutter build ios --release  # iOS
```

## 📂 Estructura del Proyecto

```
lib/
├── config/
│   ├── api_config.dart      # Configuración de endpoints
│   └── app_theme.dart        # Tema de la aplicación
├── models/
│   ├── usuario.dart          # Modelo de Usuario/Jefe
│   ├── calificacion.dart     # Modelo de Calificación
│   ├── dashboard_stats.dart  # Modelo de Estadísticas
│   └── miembro_equipo.dart   # Modelo de Miembros
├── services/
│   ├── api_service.dart      # Servicio para consumir API
│   └── auth_service.dart     # Servicio de autenticación
├── screens/
│   ├── login_screen.dart     # Pantalla de login
│   ├── home_screen.dart      # Navegación principal
│   ├── inicio_screen.dart    # Dashboard + Pendientes
│   ├── historial_screen.dart # Historial con tabs
│   ├── equipo_screen.dart    # Mi equipo
│   ├── perfil_screen.dart    # Perfil y cerrar sesión
│   └── detalle_calificacion_screen.dart
├── widgets/
│   └── cards.dart            # Widgets reutilizables
└── main.dart                 # Entrada de la aplicación
```

## 🔌 Endpoints Consumidos

La app consume los siguientes endpoints de tu API Django:

- `POST /api/login/` - Login (solo jefe)
- `GET /api/dashboard/?equipo_id=X` - Estadísticas
- `GET /api/calificaciones-pendientes/?equipo_id=X` - Pendientes
- `GET /api/calificacion/{id}/` - Detalle
- `POST /api/aprobar-calificacion/` - Aprobar
- `POST /api/rechazar-calificacion/` - Rechazar
- `GET /api/historial/?equipo_id=X&estado=Y` - Historial
- `GET /api/mi-equipo/?rut_jefe=X` - Equipo
- `GET /api/perfil/?rut=X` - Perfil
- `PUT /api/perfil/` - Actualizar perfil

## 📦 Dependencias

- `http: ^1.2.0` - Peticiones HTTP
- `shared_preferences: ^2.2.2` - Persistencia de sesión
- `fl_chart: ^0.68.0` - Gráficos
- `intl: ^0.19.0` - Formateo de fechas y números
- `provider: ^6.1.1` - State management

## 🎨 Diseño

- Cards reutilizables para calificaciones y estadísticas
- Colores por nivel de riesgo: 🟢 Bajo (Verde) | 🟡 Medio (Naranja) | 🔴 Alto (Rojo)

## 🔐 Seguridad

- Sesión persistente con `shared_preferences`
- Solo Jefes de Equipo pueden loguearse
- Validación en backend de permisos

## 👨‍💻 Desarrollo

```bash
# Ver logs
flutter logs

# Limpiar build
flutter clean

# Analizar código
flutter analyze
```
