@echo off
chcp 65001 >nul
title Arrancar App - ProyectoBase Android
echo ╔══════════════════════════════════════════════╗
echo ║   ARRANQUE RAPIDO - ProyectoBase Android    ║
echo ╚══════════════════════════════════════════════╝
echo.

REM === Verificar local.properties ===
if not exist "local.properties" (
    echo [INFO] Creando local.properties con ruta del SDK...
    echo sdk.dir=C:\\Users\\PC\\AppData\\Local\\Android\\Sdk> local.properties
    echo [OK] local.properties creado.
    echo.
)

REM === Verificar ADB ===
echo [1/4] Verificando servidor ADB...
adb start-server >nul 2>&1
echo [OK] Servidor ADB activo.
echo.

REM === Verificar dispositivo conectado ===
echo [2/4] Verificando dispositivo/emulador...
set "DEVICE_FOUND=0"
for /f "skip=1 tokens=1" %%d in ('adb devices 2^>nul') do (
    if not "%%d"=="" set "DEVICE_FOUND=1"
)

if "%DEVICE_FOUND%"=="0" (
    echo [AVISO] No hay dispositivo/emulador conectado.
    echo.
    echo Opciones:
    echo   a) Conecta tu celular por USB con depuracion USB activada
    echo   b) Inicia un emulador con: emulator -avd NOMBRE_AVD
    echo   c) Usa el menu.bat opcion 4 para iniciar un emulador
    echo.
    echo Emuladores disponibles:
    emulator -list-avds 2>nul
    echo.
    set /p iniciar_emu="Queres iniciar un emulador? (S/N): "
    if /i "!iniciar_emu!"=="S" (
        setlocal enabledelayedexpansion
        set emu_count=0
        for /f "delims=" %%a in ('emulator -list-avds 2^>nul') do (
            set /a emu_count+=1
            set "emu_!emu_count!=%%a"
            echo   !emu_count!. %%a
        )
        if !emu_count!==0 (
            echo [ERROR] No hay emuladores creados. Crea uno desde Android Studio o menu.bat opcion 3.
            pause
            exit /b 1
        )
        set /p emu_opcion="Numero del emulador: "
        set "emu_nombre=!emu_%emu_opcion%!"
        echo Iniciando !emu_nombre!...
        start "" cmd /c "emulator -avd !emu_nombre!"
        echo Esperando que el emulador arranque (30 segundos)...
        timeout /t 30 /nobreak >nul
        endlocal
    ) else (
        echo.
        echo Conecta un dispositivo y volve a ejecutar este script.
        pause
        exit /b 0
    )
)
echo [OK] Dispositivo detectado.
echo.

REM === Compilar ===
echo [3/4] Compilando proyecto...
call gradlew.bat assembleDebug
if not %ERRORLEVEL%==0 (
    echo.
    echo [ERROR] La compilacion fallo. Revisa los errores arriba.
    pause
    exit /b 1
)
echo [OK] Compilacion exitosa.
echo.

REM === Instalar y abrir ===
echo [4/4] Instalando y abriendo la app...
call adb install -r app\build\outputs\apk\debug\app-debug.apk
if not %ERRORLEVEL%==0 (
    echo [ERROR] No se pudo instalar el APK.
    pause
    exit /b 1
)
echo.
call adb shell am start -n com.ejemplo.proyectobase/.MainActivity
echo.
echo ╔══════════════════════════════════════════════╗
echo ║   [OK] App corriendo en el dispositivo!     ║
echo ╚══════════════════════════════════════════════╝
echo.
pause
exit /b 0
