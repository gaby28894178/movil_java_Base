# Proyecto Base - Hola Mundo Android

Proyecto Android base con un "Hola Mundo" listo para correr en el emulador.

> **Proyecto con fines educativos** para los compañeros de **UPATECO** (Universidad Provincial de Administración, Tecnología y Comercio) — Salta, Argentina.
>
> Realizado por el alumno **Gabriel Gabrielli**.

---

## Guía paso a paso (desde cero en un PC nuevo)

### Paso 1: Instalar requisitos previos

1. **Java JDK 17+** — Descargalo de [Adoptium](https://adoptium.net/) o [Oracle](https://www.oracle.com/java/technologies/downloads/)
2. **Android Studio** (incluye el SDK) — Descargá de [developer.android.com/studio](https://developer.android.com/studio)
   - Al instalarlo, se descarga automáticamente el Android SDK
   - La ruta por defecto del SDK es:
     - **Windows:** `C:\Users\TU_USUARIO\AppData\Local\Android\Sdk`
     - **Linux:** `~/Android/Sdk`
     - **Mac:** `~/Library/Android/sdk`

### Paso 2: Clonar o copiar el proyecto

Copiá la carpeta del proyecto a tu PC. Abrí una terminal (CMD o PowerShell) en la carpeta del proyecto.

### Paso 3: Ejecutar el instalador (hace todo automático)

**Windows:**
```cmd
instalar.bat
```

El instalador hace todo por vos:
- ✅ Detecta dónde está tu Android SDK
- ✅ Crea el archivo `local.properties` (sin esto no compila)
- ✅ Agrega al PATH: la carpeta del proyecto, `adb`, `emulator`
- ✅ Configura la variable `ANDROID_HOME`

> Después de ejecutar el instalador, **cerrá y volvé a abrir la terminal**.

**Linux/Mac:**
```bash
chmod +x menu.sh proyect.sh gradlew

# Crear local.properties manualmente:
echo "sdk.dir=$HOME/Android/Sdk" > local.properties

# Agregar al PATH (en ~/.bashrc o ~/.zshrc):
export ANDROID_HOME=~/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$ANDROID_HOME/cmdline-tools/latest/bin

# Opcional: crear alias global
echo "alias proyect='$(pwd)/proyect.sh'" >> ~/.bashrc
source ~/.bashrc
```

### Paso 4: Preparar un dispositivo

**Opción A — Celular físico:**
1. Activá "Opciones de desarrollador" (tocá 7 veces en "Número de compilación")
2. Activá "Depuración USB"
3. Conectá el celular por USB y aceptá el permiso

**Opción B — Emulador (ya creado en Android Studio):**
- Si ya creaste emuladores en Android Studio, el menú los detecta automáticamente
- Usá opción **4** del menú para iniciar uno

**Opción C — Crear emulador nuevo desde el menú:**
1. Abrí el menú (ver Paso 5)
2. Elegí opción **3** (requiere cmdline-tools instalado en el SDK)
3. Elegí opción **4** para iniciarlo
4. Esperá a que arranque completamente

### Paso 5: Correr el menú y la app

Ver la sección siguiente para los comandos según tu terminal.

---

## Cómo ejecutar el menú según tu terminal

### Windows — CMD (Command Prompt)

```cmd
proyect
```
o si no instalaste al PATH:
```cmd
menu.bat
```

### Windows — PowerShell

```powershell
.\menu.bat
```
o
```powershell
.\proyect.bat
```

> ⚠️ En PowerShell NO funciona escribir solo `start` o `proyect` sin el `.\` adelante.
> PowerShell interpreta `start` como `Start-Process` y te pide parámetros.

### Windows — Terminal de VS Code

Si tu terminal por defecto es PowerShell, usá:
```powershell
.\menu.bat
```

Si querés usar CMD en VS Code: hacé clic en la flechita `▾` al lado del `+` en la terminal y elegí **"Command Prompt"**. Ahí podés escribir directamente:
```cmd
proyect
```

### Linux / Mac

```bash
chmod +x menu.sh gradlew   # Solo la primera vez
./menu.sh
```
o si creaste el alias:
```bash
proyect
```

---

## Resumen rápido (si ya tenés todo instalado)

**Windows (CMD):**
```cmd
proyect
REM Elegir opcion 6
```

**Windows (PowerShell):**
```powershell
.\menu.bat
# Elegir opcion 6
```

**Linux/Mac:**
```bash
./menu.sh
# Elegir opcion 6
```

La opción **6** hace todo: compila → instala → abre la app.

---

## Solución de problemas comunes

| Error | Causa | Solución |
|-------|-------|----------|
| `SDK location not found` | Falta `local.properties` o la ruta está mal | Creá el archivo con la ruta correcta del SDK (ver Paso 3) |
| `start` pide `FilePath` en PowerShell | PowerShell interpreta `start` como `Start-Process` | Usá `.\menu.bat` o `.\proyect.bat` en vez de `start` o `proyect` |
| `No se pudo instalar el APK` | No hay dispositivo/emulador conectado | Conectá un celular o iniciá un emulador (ver Paso 5) |
| `gradlew no se reconoce` | No estás en la carpeta del proyecto | Navegá a la carpeta con `cd` |
| `emulator no se reconoce` | Falta el SDK en el PATH | Agregá las rutas del SDK al PATH (ver Paso 1) |
| `java no se reconoce` | No tenés Java instalado | Instalá JDK 17+ (ver Paso 1) |
| `Permission denied` (Linux) | Falta permiso de ejecución | Ejecutá `chmod +x menu.sh gradlew` |

### Verificar que todo está bien

```bash
java -version            # Debe decir 17 o superior
adb devices              # Debe listar tu dispositivo
emulator -list-avds      # Debe listar tus emuladores
./gradlew --version      # Linux/Mac (Gradle 8.6)
.\gradlew.bat --version  # Windows (Gradle 8.6)
```

---

## Estructura del proyecto

```
proyecto-base/
├── app/
│   ├── build.gradle                    # Configuración del módulo app
│   ├── proguard-rules.pro
│   └── src/main/
│       ├── AndroidManifest.xml         # Manifest de la app
│       ├── java/com/ejemplo/proyectobase/
│       │   └── MainActivity.java       # Activity principal
│       └── res/
│           ├── layout/
│           │   └── activity_main.xml   # Layout con el Hola Mundo
│           └── values/
│               ├── strings.xml         # Textos
│               └── themes.xml          # Tema de la app
├── gradle/wrapper/
│   ├── gradle-wrapper.jar
│   └── gradle-wrapper.properties       # Versión de Gradle: 8.6
├── build.gradle                        # Build raíz (AGP 8.4.0)
├── settings.gradle                     # Configuración del proyecto
├── gradle.properties                   # Propiedades de Gradle
├── local.properties                    # ⚠️ RUTA DEL SDK (crear manualmente)
├── gradlew                             # Wrapper Linux/Mac
├── gradlew.bat                         # Wrapper Windows
├── proyect.bat                         # Lanzador del menú (Windows)
├── proyect.sh                          # Lanzador del menú (Linux/Mac)
├── menu.bat                            # Menú interactivo (Windows)
├── menu.sh                             # Menú interactivo (Linux/Mac)
├── arrancar.bat                        # Arranque rápido (Windows)
├── instalar.bat                        # Agrega proyecto al PATH (Windows)
├── desinstalar.bat                     # Remueve proyecto del PATH (Windows)
└── README.md
```

## Versiones utilizadas

| Componente | Versión |
|---|---|
| Gradle | 8.6 |
| Android Gradle Plugin (AGP) | 8.4.0 |
| compileSdk | 34 |
| minSdk | 24 |
| targetSdk | 34 |
| Java | 17 |

---

## Menú interactivo — Opciones

| # | Opción | Qué hace |
|---|--------|----------|
| 1 | Compilar proyecto | Ejecuta `gradlew assembleDebug` y genera el APK |
| 2 | Listar emuladores disponibles | Muestra los AVD creados |
| 3 | Crear emulador (AVD) | Descarga imagen API 34 y crea un emulador |
| 4 | Iniciar emulador | Seleccionás un emulador y se lanza |
| 5 | Instalar APK | Instala el APK en el dispositivo/emulador |
| 6 | Correr app | **Compila + Instala + Abre** (todo junto) |
| 7 | Limpiar proyecto | Ejecuta `gradlew clean` |
| 8 | Borrar APK generado | Elimina el APK de debug |
| 9 | Limpiar cache de la app | Borra datos de la app en el dispositivo |
| 10 | Listar dispositivos conectados | Muestra dispositivos que detecta `adb` |
| 0 | Salir | Cierra el menú |

---

## Cómo modificar la app

- **Cambiar el texto**: Editá `app/src/main/res/layout/activity_main.xml`
- **Agregar lógica**: Editá `app/src/main/java/com/ejemplo/proyectobase/MainActivity.java`
- **Cambiar nombre de la app**: Editá `app/src/main/res/values/strings.xml`
- **Cambiar colores/tema**: Editá `app/src/main/res/values/themes.xml`

---

## Desinstalar el comando global

**Windows:**
```bash
desinstalar.bat
```

**Linux/Mac:**
Eliminá la línea del alias en `~/.bashrc` o `~/.zshrc`.
"# movil_java_Base" 
