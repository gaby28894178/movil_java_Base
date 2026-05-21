@echo off
chcp 65001 >nul
title Menu - ProyectoBase Android
setlocal enabledelayedexpansion

REM === Detectar SDK automaticamente ===
set "SDK_PATH="
if defined ANDROID_HOME (
    set "SDK_PATH=%ANDROID_HOME%"
)
if not defined SDK_PATH (
    if exist "%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe" (
        set "SDK_PATH=%LOCALAPPDATA%\Android\Sdk"
    )
)

REM Configurar rutas de herramientas
if defined SDK_PATH (
    set "ADB=!SDK_PATH!\platform-tools\adb.exe"
    set "EMULATOR=!SDK_PATH!\emulator\emulator.exe"
    set "SDKMANAGER=!SDK_PATH!\cmdline-tools\latest\bin\sdkmanager.bat"
    set "AVDMANAGER=!SDK_PATH!\cmdline-tools\latest\bin\avdmanager.bat"
) else (
    REM Fallback: intentar usar del PATH
    set "ADB=adb"
    set "EMULATOR=emulator"
    set "SDKMANAGER=sdkmanager"
    set "AVDMANAGER=avdmanager"
)

:MENU
cls
echo ╔══════════════════════════════════════════════╗
echo ║       MENU - ProyectoBase Android           ║
echo ╠══════════════════════════════════════════════╣
echo ║  1. Compilar proyecto (assembleDebug)       ║
echo ║  2. Listar emuladores disponibles           ║
echo ║  3. Crear emulador (AVD)                    ║
echo ║  4. Iniciar emulador                        ║
echo ║  5. Instalar APK en dispositivo/emulador    ║
echo ║  6. Correr app (compilar + instalar + abrir)║
echo ║  7. Limpiar proyecto (clean)                ║
echo ║  8. Borrar APK generado                     ║
echo ║  9. Limpiar cache de la app (dispositivo)   ║
echo ║ 10. Listar dispositivos conectados (adb)    ║
echo ║  0. Salir                                   ║
echo ╚══════════════════════════════════════════════╝
if defined SDK_PATH (
    echo  SDK: !SDK_PATH!
) else (
    echo  [AVISO] SDK no detectado. Ejecuta instalar.bat primero.
)
echo.
set /p opcion="Selecciona una opcion: "

if "%opcion%"=="1" goto COMPILAR
if "%opcion%"=="2" goto LISTAR_AVD
if "%opcion%"=="3" goto CREAR_AVD
if "%opcion%"=="4" goto INICIAR_AVD
if "%opcion%"=="5" goto INSTALAR
if "%opcion%"=="6" goto CORRER
if "%opcion%"=="7" goto LIMPIAR
if "%opcion%"=="8" goto BORRAR_APK
if "%opcion%"=="9" goto LIMPIAR_CACHE
if "%opcion%"=="10" goto DISPOSITIVOS
if "%opcion%"=="0" goto SALIR

echo Opcion no valida.
pause
goto MENU

:COMPILAR
cls
echo === Compilando proyecto (assembleDebug) ===
call gradlew.bat assembleDebug
echo.
if %ERRORLEVEL%==0 (
    echo [OK] Compilacion exitosa.
    echo APK generado en: app\build\outputs\apk\debug\app-debug.apk
) else (
    echo [ERROR] La compilacion fallo.
)
echo.
pause
goto MENU

:LISTAR_AVD
cls
echo === Emuladores disponibles ===
"!EMULATOR!" -list-avds
echo.
pause
goto MENU

:CREAR_AVD
cls
echo === Crear nuevo emulador (AVD) ===
echo.

REM Verificar si cmdline-tools existe
if not exist "!AVDMANAGER!" (
    echo [INFO] cmdline-tools no esta instalado. Instalando automaticamente...
    echo.
    echo Descargando Android SDK Command-line Tools...
    echo.

    REM Crear carpeta temporal
    if not exist "!SDK_PATH!\cmdline-tools-temp" mkdir "!SDK_PATH!\cmdline-tools-temp"

    REM Descargar cmdline-tools con curl (viene con Windows 10+)
    curl -L -o "!SDK_PATH!\cmdline-tools-temp\cmdline-tools.zip" "https://dl.google.com/android/repository/commandlinetools-win-11076708_latest.zip"
    if not %ERRORLEVEL%==0 (
        echo [ERROR] No se pudo descargar cmdline-tools.
        echo Verifica tu conexion a internet.
        rmdir /s /q "!SDK_PATH!\cmdline-tools-temp" 2>nul
        pause
        goto MENU
    )

    echo Extrayendo...
    REM Extraer con PowerShell (disponible en Windows 10+)
    powershell -Command "Expand-Archive -Path '!SDK_PATH!\cmdline-tools-temp\cmdline-tools.zip' -DestinationPath '!SDK_PATH!\cmdline-tools-temp\extracted' -Force"
    if not %ERRORLEVEL%==0 (
        echo [ERROR] No se pudo extraer el archivo.
        rmdir /s /q "!SDK_PATH!\cmdline-tools-temp" 2>nul
        pause
        goto MENU
    )

    REM Mover a la ubicacion correcta (cmdline-tools/latest/)
    if not exist "!SDK_PATH!\cmdline-tools" mkdir "!SDK_PATH!\cmdline-tools"
    if exist "!SDK_PATH!\cmdline-tools\latest" rmdir /s /q "!SDK_PATH!\cmdline-tools\latest"
    move "!SDK_PATH!\cmdline-tools-temp\extracted\cmdline-tools" "!SDK_PATH!\cmdline-tools\latest" >nul

    REM Limpiar temporal
    rmdir /s /q "!SDK_PATH!\cmdline-tools-temp" 2>nul

    REM Verificar que se instalo
    if exist "!SDK_PATH!\cmdline-tools\latest\bin\sdkmanager.bat" (
        set "SDKMANAGER=!SDK_PATH!\cmdline-tools\latest\bin\sdkmanager.bat"
        set "AVDMANAGER=!SDK_PATH!\cmdline-tools\latest\bin\avdmanager.bat"
        echo [OK] cmdline-tools instalado correctamente.
        echo.
    ) else (
        echo [ERROR] La instalacion fallo. Intenta instalar manualmente desde Android Studio:
        echo   Settings ^> SDK Manager ^> SDK Tools ^> "Android SDK Command-line Tools"
        echo.
        pause
        goto MENU
    )
)

echo Aceptando licencias...
echo y | call "!SDKMANAGER!" --licenses >nul 2>&1
echo.

echo Descargando imagen del sistema (si no existe)...
call "!SDKMANAGER!" "system-images;android-34;google_apis;x86_64"
if not %ERRORLEVEL%==0 (
    echo [ERROR] No se pudo descargar la imagen del sistema.
    echo Verifica tu conexion a internet.
    pause
    goto MENU
)
echo.
set /p avd_nombre="Nombre para el emulador (ej: Pixel_API34): "
echo Creando AVD: %avd_nombre%
echo no | call "!AVDMANAGER!" create avd -n %avd_nombre% -k "system-images;android-34;google_apis;x86_64" -d "pixel"
echo.
if %ERRORLEVEL%==0 (
    echo [OK] Emulador "%avd_nombre%" creado correctamente.
    echo Usa la opcion 4 para iniciarlo.
) else (
    echo [ERROR] No se pudo crear el emulador.
)
echo.
pause
goto MENU

:INICIAR_AVD
cls
echo === Iniciar emulador ===
echo.
REM Verificar ADB
echo Verificando servidor ADB...
"!ADB!" devices >nul 2>&1
if not %ERRORLEVEL%==0 (
    echo [INFO] Iniciando servidor ADB...
    "!ADB!" start-server
)
echo [OK] Servidor ADB activo.
echo.
echo Emuladores disponibles:
echo.
set avd_count=0
for /f "delims=" %%a in ('"!EMULATOR!" -list-avds 2^>nul') do (
    set /a avd_count+=1
    set "avd_!avd_count!=%%a"
    echo   !avd_count!. %%a
)
echo.
if !avd_count!==0 (
    echo [ERROR] No hay emuladores creados. Usa la opcion 3 para crear uno.
    echo.
    pause
    goto MENU
)
set /p avd_opcion="Selecciona el numero del emulador: "
if !avd_opcion! LSS 1 (
    echo Opcion no valida.
    pause
    goto MENU
)
if !avd_opcion! GTR !avd_count! (
    echo Opcion no valida.
    pause
    goto MENU
)
set "avd_nombre=!avd_%avd_opcion%!"
echo.
echo Iniciando !avd_nombre! en una nueva ventana...
start "Emulador Android - !avd_nombre!" cmd /c ""!EMULATOR!" -avd !avd_nombre!"
echo.
echo [OK] Emulador lanzado en una ventana separada.
echo Espera a que termine de arrancar antes de instalar la app.
echo.
pause
goto MENU

:INSTALAR
cls
echo === Instalar APK en dispositivo/emulador ===
REM Verificar ADB
echo Verificando servidor ADB...
"!ADB!" start-server >nul 2>&1
echo [OK] Servidor ADB activo.
echo.
if not exist "app\build\outputs\apk\debug\app-debug.apk" (
    echo [AVISO] No se encontro el APK. Compilando primero...
    call gradlew.bat assembleDebug
    echo.
)
echo Instalando APK...
"!ADB!" install -r app\build\outputs\apk\debug\app-debug.apk
echo.
if %ERRORLEVEL%==0 (
    echo [OK] APK instalado correctamente.
) else (
    echo [ERROR] No se pudo instalar el APK. Verifica que haya un dispositivo conectado.
)
echo.
pause
goto MENU

:CORRER
cls
echo === Compilar + Instalar + Abrir App ===
echo.
REM Verificar ADB
echo Verificando servidor ADB...
"!ADB!" start-server >nul 2>&1
echo [OK] Servidor ADB activo.
echo.
echo [1/3] Compilando...
call gradlew.bat assembleDebug
if not %ERRORLEVEL%==0 (
    echo [ERROR] La compilacion fallo. Abortando.
    pause
    goto MENU
)
echo.
echo [2/3] Instalando APK...
"!ADB!" install -r app\build\outputs\apk\debug\app-debug.apk
if not %ERRORLEVEL%==0 (
    echo [ERROR] No se pudo instalar. Verifica dispositivo/emulador.
    pause
    goto MENU
)
echo.
echo [3/3] Abriendo app...
"!ADB!" shell am start -n com.ejemplo.proyectobase/.MainActivity
echo.
if %ERRORLEVEL%==0 (
    echo [OK] App ejecutandose en el dispositivo.
) else (
    echo [ERROR] No se pudo abrir la app.
)
echo.
pause
goto MENU

:LIMPIAR
cls
echo === Limpiando proyecto ===
call gradlew.bat clean
echo.
if %ERRORLEVEL%==0 (
    echo [OK] Proyecto limpiado.
) else (
    echo [ERROR] Fallo al limpiar.
)
echo.
pause
goto MENU

:BORRAR_APK
cls
echo === Borrar APK generado ===
if exist "app\build\outputs\apk\debug\app-debug.apk" (
    del /f "app\build\outputs\apk\debug\app-debug.apk"
    echo [OK] APK eliminado: app\build\outputs\apk\debug\app-debug.apk
) else (
    echo [INFO] No hay APK generado para borrar.
)
echo.
pause
goto MENU

:LIMPIAR_CACHE
cls
echo === Limpiar cache de la app en dispositivo/emulador ===
echo.
echo Verificando servidor ADB...
"!ADB!" start-server >nul 2>&1
echo [OK] Servidor ADB activo.
echo.
echo Limpiando cache de com.ejemplo.proyectobase...
"!ADB!" shell pm clear com.ejemplo.proyectobase
echo.
if %ERRORLEVEL%==0 (
    echo [OK] Cache y datos de la app eliminados del dispositivo.
) else (
    echo [ERROR] No se pudo limpiar. Verifica que la app este instalada y haya un dispositivo conectado.
)
echo.
pause
goto MENU

:DISPOSITIVOS
cls
echo === Dispositivos conectados ===
"!ADB!" devices
echo.
pause
goto MENU

:SALIR
echo Hasta luego!
exit /b 0
