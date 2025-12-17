@echo off
echo ====================================
echo    NUAM - Configuracion de Logos
echo ====================================
echo.

echo [1/3] Verificando carpeta de assets...
if not exist "assets\images" (
    echo ERROR: La carpeta assets\images no existe
    echo Por favor, ejecuta este script desde la carpeta app_movil_nuam
    pause
    exit /b 1
)
echo OK - Carpeta assets\images existe
echo.

echo [2/3] Verificando archivos de logo...
set MISSING=0

if not exist "assets\images\logo_nuam.png" (
    echo FALTA: logo_nuam.png
    set MISSING=1
) else (
    echo OK - logo_nuam.png encontrado
)

if not exist "assets\images\logo_footer.png" (
    echo FALTA: logo_footer.png
    set MISSING=1
) else (
    echo OK - logo_footer.png encontrado
)

if %MISSING%==1 (
    echo.
    echo IMPORTANTE: Copia manualmente los archivos de logo a:
    echo   %CD%\assets\images\
    echo.
    echo Archivos requeridos:
    echo   - logo_nuam.png   (logo grande para login)
    echo   - logo_footer.png (logo pequeno para icono de app)
    echo.
    echo Despues de copiar los archivos, ejecuta este script nuevamente.
    pause
    exit /b 1
)

echo.
echo [3/3] Actualizando proyecto Flutter...
echo Ejecutando: flutter pub get
flutter pub get

if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Fallo flutter pub get
    pause
    exit /b 1
)

echo.
echo ====================================
echo   Configuracion completada!
echo ====================================
echo.
echo Los logos estan listos para usar.
echo.
echo Siguientes pasos:
echo   1. Ejecuta: flutter clean
echo   2. Ejecuta: flutter run
echo.
echo Para configurar el icono de la app:
echo   1. Agrega flutter_launcher_icons a pubspec.yaml
echo   2. Ejecuta: flutter pub run flutter_launcher_icons
echo.
echo Consulta GUIA_LOGOS_NUAM.md para mas detalles.
echo.
pause
