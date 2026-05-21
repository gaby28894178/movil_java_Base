@echo off
chcp 65001 >nul
echo ╔══════════════════════════════════════════════╗
echo ║  Desinstalar - ProyectoBase Android Menu    ║
echo ╚══════════════════════════════════════════════╝
echo.
echo Este script remueve la carpeta del proyecto del PATH del usuario.
echo.
set /p confirmar="Deseas continuar? (S/N): "
if /i not "%confirmar%"=="S" (
    echo Cancelado.
    pause
    exit /b 0
)

REM Obtener el PATH actual del usuario
for /f "tokens=2*" %%a in ('reg query "HKCU\Environment" /v Path 2^>nul') do set "USER_PATH=%%b"

REM Remover la carpeta del PATH
set "NEW_PATH=!USER_PATH!"
setlocal enabledelayedexpansion
set "NEW_PATH=!USER_PATH:%~dp0=!"
REM Limpiar punto y coma doble que pueda quedar
set "NEW_PATH=!NEW_PATH:;;=;!"
REM Limpiar punto y coma al final
if "!NEW_PATH:~-1!"==";" set "NEW_PATH=!NEW_PATH:~0,-1!"

setx PATH "!NEW_PATH!"
echo.
if %ERRORLEVEL%==0 (
    echo [OK] Carpeta removida del PATH.
    echo Cerra y volve a abrir la terminal para que tome efecto.
) else (
    echo [ERROR] No se pudo modificar el PATH.
)
echo.
pause
exit /b 0
