#!/bin/bash
# Menu interactivo - ProyectoBase Android (Linux/Mac)
# Por: Gabriel Gabrielli - UPATECO Salta

show_menu() {
    clear
    echo "╔══════════════════════════════════════════════╗"
    echo "║       MENU - ProyectoBase Android           ║"
    echo "╠══════════════════════════════════════════════╣"
    echo "║  1. Compilar proyecto (assembleDebug)       ║"
    echo "║  2. Listar emuladores disponibles           ║"
    echo "║  3. Crear emulador (AVD)                    ║"
    echo "║  4. Iniciar emulador                        ║"
    echo "║  5. Instalar APK en dispositivo/emulador    ║"
    echo "║  6. Correr app (compilar + instalar + abrir)║"
    echo "║  7. Limpiar proyecto (clean)                ║"
    echo "║  8. Borrar APK generado                     ║"
    echo "║  9. Limpiar cache de la app (dispositivo)   ║"
    echo "║ 10. Listar dispositivos conectados (adb)    ║"
    echo "║  0. Salir                                   ║"
    echo "╚══════════════════════════════════════════════╝"
    echo ""
    read -p "Selecciona una opcion: " opcion
}

compilar() {
    echo "=== Compilando proyecto (assembleDebug) ==="
    ./gradlew assembleDebug
    if [ $? -eq 0 ]; then
        echo ""
        echo "[OK] Compilacion exitosa."
        echo "APK generado en: app/build/outputs/apk/debug/app-debug.apk"
    else
        echo ""
        echo "[ERROR] La compilacion fallo."
    fi
}

listar_avd() {
    echo "=== Emuladores disponibles ==="
    emulator -list-avds
}

crear_avd() {
    echo "=== Crear nuevo emulador (AVD) ==="
    echo ""
    echo "Descargando imagen del sistema (si no existe)..."
    sdkmanager "system-images;android-34;google_apis;x86_64"
    echo ""
    read -p "Nombre para el emulador (ej: Pixel_API34): " avd_nombre
    echo "Creando AVD: $avd_nombre"
    avdmanager create avd -n "$avd_nombre" -k "system-images;android-34;google_apis;x86_64" -d "pixel"
    if [ $? -eq 0 ]; then
        echo "[OK] Emulador \"$avd_nombre\" creado correctamente."
    else
        echo "[ERROR] No se pudo crear el emulador."
    fi
}

iniciar_avd() {
    echo "=== Iniciar emulador ==="
    echo ""
    echo "Verificando servidor ADB..."
    adb start-server 2>/dev/null
    echo "[OK] Servidor ADB activo."
    echo ""
    echo "Emuladores disponibles:"
    echo ""

    avds=()
    while IFS= read -r line; do
        if [ -n "$line" ]; then
            avds+=("$line")
        fi
    done < <(emulator -list-avds 2>/dev/null)

    if [ ${#avds[@]} -eq 0 ]; then
        echo "[ERROR] No hay emuladores creados. Usa la opcion 3 para crear uno."
        return
    fi

    for i in "${!avds[@]}"; do
        echo "  $((i+1)). ${avds[$i]}"
    done
    echo ""
    read -p "Selecciona el numero del emulador: " avd_opcion

    idx=$((avd_opcion-1))
    if [ $idx -lt 0 ] || [ $idx -ge ${#avds[@]} ]; then
        echo "Opcion no valida."
        return
    fi

    avd_nombre="${avds[$idx]}"
    echo ""
    echo "Iniciando $avd_nombre..."
    emulator -avd "$avd_nombre" &
    echo ""
    echo "[OK] Emulador lanzado en segundo plano."
    echo "Espera a que termine de arrancar antes de instalar la app."
}

instalar_apk() {
    echo "=== Instalar APK en dispositivo/emulador ==="
    echo "Verificando servidor ADB..."
    adb start-server 2>/dev/null
    echo "[OK] Servidor ADB activo."
    echo ""

    if [ ! -f "app/build/outputs/apk/debug/app-debug.apk" ]; then
        echo "[AVISO] No se encontro el APK. Compilando primero..."
        ./gradlew assembleDebug
        echo ""
    fi

    echo "Instalando APK..."
    adb install -r app/build/outputs/apk/debug/app-debug.apk
    if [ $? -eq 0 ]; then
        echo "[OK] APK instalado correctamente."
    else
        echo "[ERROR] No se pudo instalar el APK. Verifica que haya un dispositivo conectado."
    fi
}

correr_app() {
    echo "=== Compilar + Instalar + Abrir App ==="
    echo ""
    echo "Verificando servidor ADB..."
    adb start-server 2>/dev/null
    echo "[OK] Servidor ADB activo."
    echo ""

    echo "[1/3] Compilando..."
    ./gradlew assembleDebug
    if [ $? -ne 0 ]; then
        echo "[ERROR] La compilacion fallo. Abortando."
        return
    fi

    echo ""
    echo "[2/3] Instalando APK..."
    adb install -r app/build/outputs/apk/debug/app-debug.apk
    if [ $? -ne 0 ]; then
        echo "[ERROR] No se pudo instalar. Verifica dispositivo/emulador."
        return
    fi

    echo ""
    echo "[3/3] Abriendo app..."
    adb shell am start -n com.ejemplo.proyectobase/.MainActivity
    if [ $? -eq 0 ]; then
        echo ""
        echo "[OK] App ejecutandose en el dispositivo."
    else
        echo "[ERROR] No se pudo abrir la app."
    fi
}

limpiar() {
    echo "=== Limpiando proyecto ==="
    ./gradlew clean
    if [ $? -eq 0 ]; then
        echo "[OK] Proyecto limpiado."
    else
        echo "[ERROR] Fallo al limpiar."
    fi
}

borrar_apk() {
    echo "=== Borrar APK generado ==="
    if [ -f "app/build/outputs/apk/debug/app-debug.apk" ]; then
        rm -f app/build/outputs/apk/debug/app-debug.apk
        echo "[OK] APK eliminado."
    else
        echo "[INFO] No hay APK generado para borrar."
    fi
}

limpiar_cache() {
    echo "=== Limpiar cache de la app en dispositivo/emulador ==="
    echo "Verificando servidor ADB..."
    adb start-server 2>/dev/null
    echo "[OK] Servidor ADB activo."
    echo ""
    echo "Limpiando cache de com.ejemplo.proyectobase..."
    adb shell pm clear com.ejemplo.proyectobase
    if [ $? -eq 0 ]; then
        echo "[OK] Cache y datos de la app eliminados del dispositivo."
    else
        echo "[ERROR] No se pudo limpiar. Verifica que la app este instalada."
    fi
}

dispositivos() {
    echo "=== Dispositivos conectados ==="
    adb devices
}

# === LOOP PRINCIPAL ===
while true; do
    show_menu
    case $opcion in
        1) compilar ;;
        2) listar_avd ;;
        3) crear_avd ;;
        4) iniciar_avd ;;
        5) instalar_apk ;;
        6) correr_app ;;
        7) limpiar ;;
        8) borrar_apk ;;
        9) limpiar_cache ;;
        10) dispositivos ;;
        0) echo "Hasta luego!"; exit 0 ;;
        *) echo "Opcion no valida." ;;
    esac
    echo ""
    read -p "Presiona Enter para volver al menu..." dummy
done
