@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
title Instalador - ProyectoBase Android
echo ╔══════════════════════════════════════════════╗
echo ║  INSTALADOR - ProyectoBase Android          ║
echo ║  Por: Gabriel Gabrielli - UPATECO Salta     ║
echo ╚══════════════════════════════════════════════╝
echo.
echo Este instalador configura todo lo necesario para compilar y correr el proyecto.
echo.

REM === 1. Detectar SDK ===
echo [1/4] Buscando Android SDK...
set "SDK_PATH="

REM Intentar ANDROID_HOME
if defined ANDROID_HOME (
    if exist "%ANDROID_HOME%\platform-tools\adb.exe" (
        set "SDK_PATH=%ANDROID_HOME%"
    )
)

REM Intentar ruta por defecto
if not defined SDK_PATH (
    if exist "%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe" (
        set "SDK_PATH=%LOCALAPPDATA%\Android\Sdk"
    )
)

REM Intentar otra ruta comun
if not defined SDK_PATH (
    if exist "C:\Android\Sdk\platform-tools\adb.exe" (
        set "SDK_PATH=C:\Android\Sdk"
    )
)

if not defined SDK_PATH (
    echo [ERROR] No se encontro el Android SDK.
    echo.
    echo Instala Android Studio desde: https://developer.android.com/studio
    echo Despues volve a ejecutar este instalador.
    echo.
    pause
    exit /b 1
)

echo [OK] SDK encontrado en: !SDK_PATH!
echo.

REM === 2. Crear local.properties ===
echo [2/4] Configurando local.properties...
set "SDK_ESCAPED=!SDK_PATH:\=\\!"
echo sdk.dir=!SDK_ESCAPED!> local.properties
echo [OK] local.properties creado con ruta: !SDK_PATH!
echo.

REM === 3. Configurar PATH del usuario ===
echo [3/4] Configurando PATH del sistema...
echo.
echo Se van a agregar al PATH:
echo   - Carpeta del proyecto (para comando "proyect")
echo   - SDK platform-tools (para "adb")
echo   - SDK emulator (para "emulator")
echo.

REM Obtener PATH actual del usuario
for /f "tokens=2*" %%a in ('reg query "HKCU\Environment" /v Path 2^>nul') do set "USER_PATH=%%b"

set "PATHS_TO_ADD="
set "ADDED_SOMETHING=0"

REM Verificar carpeta del proyecto
echo %USER_PATH% | findstr /i /c:"%~dp0" >nul 2>&1
if not %ERRORLEVEL%==0 (
    set "PATHS_TO_ADD=!PATHS_TO_ADD!;%~dp0"
    set "ADDED_SOMETHING=1"
    echo   [+] %~dp0
) else (
    echo   [=] Carpeta del proyecto ya esta en PATH
)

REM Verificar platform-tools
echo %USER_PATH% | findstr /i /c:"!SDK_PATH!\platform-tools" >nul 2>&1
if not %ERRORLEVEL%==0 (
    set "PATHS_TO_ADD=!PATHS_TO_ADD!;!SDK_PATH!\platform-tools"
    set "ADDED_SOMETHING=1"
    echo   [+] !SDK_PATH!\platform-tools
) else (
    echo   [=] platform-tools ya esta en PATH
)

REM Verificar emulator
echo %USER_PATH% | findstr /i /c:"!SDK_PATH!\emulator" >nul 2>&1
if not %ERRORLEVEL%==0 (
    set "PATHS_TO_ADD=!PATHS_TO_ADD!;!SDK_PATH!\emulator"
    set "ADDED_SOMETHING=1"
    echo   [+] !SDK_PATH!\emulator
) else (
    echo   [=] emulator ya esta en PATH
)

REM Verificar cmdline-tools (si existe)
if exist "!SDK_PATH!\cmdline-tools\latest\bin" (
    echo %USER_PATH% | findstr /i /c:"!SDK_PATH!\cmdline-tools\latest\bin" >nul 2>&1
    if not %ERRORLEVEL%==0 (
        set "PATHS_TO_ADD=!PATHS_TO_ADD!;!SDK_PATH!\cmdline-tools\latest\bin"
        set "ADDED_SOMETHING=1"
        echo   [+] !SDK_PATH!\cmdline-tools\latest\bin
    ) else (
        echo   [=] cmdline-tools ya esta en PATH
    )
)

echo.

if "!ADDED_SOMETHING!"=="1" (
    set /p confirmar="Agregar estas rutas al PATH? (S/N): "
    if /i not "!confirmar!"=="S" (
        echo Saltando configuracion de PATH.
        goto SKIP_PATH
    )
    if defined USER_PATH (
        setx PATH "!USER_PATH!!PATHS_TO_ADD!"
    ) else (
        set "CLEAN_PATHS=!PATHS_TO_ADD:~1!"
        setx PATH "!CLEAN_PATHS!"
    )
    if %ERRORLEVEL%==0 (
        echo [OK] PATH actualizado correctamente.
    ) else (
        echo [ERROR] No se pudo actualizar el PATH.
    )
) else (
    echo [OK] Todo ya esta en el PATH, no hay cambios necesarios.
)

:SKIP_PATH
echo.

REM === 4. Configurar ANDROID_HOME ===
echo [4/4] Configurando variable ANDROID_HOME...
if defined ANDROID_HOME (
    echo [OK] ANDROID_HOME ya esta configurada: %ANDROID_HOME%
) else (
    setx ANDROID_HOME "!SDK_PATH!" >nul 2>&1
    if %ERRORLEVEL%==0 (
        echo [OK] ANDROID_HOME configurada: !SDK_PATH!
    ) else (
        echo [AVISO] No se pudo configurar ANDROID_HOME automaticamente.
        echo Configurala manualmente: ANDROID_HOME = !SDK_PATH!
    )
)

echo.
echo ╔══════════════════════════════════════════════╗
echo ║         INSTALACION COMPLETADA              ║
echo ╠══════════════════════════════════════════════╣
echo ║                                             ║
echo ║  IMPORTANTE: Cerra y volve a abrir la       ║
echo ║  terminal para que los cambios tomen efecto ║
echo ║                                             ║
echo ║  Despues podes usar:                        ║
echo ║    CMD:        proyect                      ║
echo ║    PowerShell: .\menu.bat                   ║
echo ║                                             ║
echo ╚══════════════════════════════════════════════╝
echo.
pause
exit /b 0
