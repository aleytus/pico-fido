@echo off
setlocal EnableDelayedExpansion

REM ==============================================================================
REM 0. КОНФИГУРАЦИЯ
REM ==============================================================================
set "PROJECT_ROOT=%CD%"
set "UTILS_DIR=%PROJECT_ROOT%\utils"

REM Ссылки на инструменты
set "URL_CMAKE=https://github.com/Kitware/CMake/releases/download/v4.2.2/cmake-4.2.2-windows-x86_64.zip"
set "URL_NINJA=https://github.com/ninja-build/ninja/releases/download/v1.13.2/ninja-win.zip"
set "URL_ARM_GCC=https://developer.arm.com/-/media/Files/downloads/gnu/15.2.rel1/binrel/arm-gnu-toolchain-15.2.rel1-mingw-w64-x86_64-arm-none-eabi.zip"
set "URL_PYTHON=https://www.python.org/ftp/python/3.14.2/python-3.14.2-embed-amd64.zip"
set "URL_PICOTOOL=https://github.com/raspberrypi/pico-sdk-tools/releases/download/v2.2.0-3/picotool-2.2.0-a4-x64-win.zip"

if not exist "%UTILS_DIR%" mkdir "%UTILS_DIR%"

REM ==============================================================================
REM 1. ЗАГРУЗКА ИНСТРУМЕНТОВ
REM ==============================================================================

REM --- 1.1 Python ---
if not exist "%UTILS_DIR%\python" (
    echo [INFO] Downloading Python...
    curl -L -o "%UTILS_DIR%\python.zip" %URL_PYTHON%
    mkdir "%UTILS_DIR%\python"
    tar -xf "%UTILS_DIR%\python.zip" -C "%UTILS_DIR%\python"
)
set "PATH=%UTILS_DIR%\python;%PATH%"

REM --- 1.2 CMake ---
if not exist "%UTILS_DIR%\cmake" (
    echo [INFO] Downloading CMake...
    curl -L -o "%UTILS_DIR%\cmake.zip" %URL_CMAKE%
    mkdir "%UTILS_DIR%\cmake"
    tar -xf "%UTILS_DIR%\cmake.zip" -C "%UTILS_DIR%\cmake"
)
for /d %%d in ("%UTILS_DIR%\cmake\cmake-*") do (
    if exist "%%d\bin\cmake.exe" set "PATH=%%d\bin;!PATH!"
)

REM --- 1.3 Ninja ---
if not exist "%UTILS_DIR%\ninja" (
    echo [INFO] Downloading Ninja...
    curl -L -o "%UTILS_DIR%\ninja.zip" %URL_NINJA%
    mkdir "%UTILS_DIR%\ninja"
    tar -xf "%UTILS_DIR%\ninja.zip" -C "%UTILS_DIR%\ninja"
)
set "PATH=%UTILS_DIR%\ninja;%PATH%"

REM --- 1.4 ARM GCC ---
if not exist "%UTILS_DIR%\arm-gcc" (
    echo [INFO] Downloading ARM GCC...
    curl -L -o "%UTILS_DIR%\arm-gcc.zip" %URL_ARM_GCC%
    mkdir "%UTILS_DIR%\arm-gcc"
    tar -xf "%UTILS_DIR%\arm-gcc.zip" -C "%UTILS_DIR%\arm-gcc"
)
set "PATH=%UTILS_DIR%\arm-gcc\bin;%PATH%"
set "PICO_TOOLCHAIN_PATH=%UTILS_DIR%\arm-gcc"

REM --- 1.5 Picotool ---
if not exist "%UTILS_DIR%\picotool" (
    echo [INFO] Downloading Pre-built Picotool...
    curl -L -o "%UTILS_DIR%\picotool.zip" %URL_PICOTOOL%
    mkdir "%UTILS_DIR%\picotool"
    tar -xf "%UTILS_DIR%\picotool.zip" -C "%UTILS_DIR%\picotool"
)
set "PATH=%UTILS_DIR%\picotool\picotool;%PATH%"

REM ==============================================================================
REM 2. ПОДГОТОВКА И СБОРКА ПРОШИВКИ
REM ==============================================================================
cd /d "%PROJECT_ROOT%"

if exist "pico-keys-sdk\mbedtls" (
    echo [INFO] Configuring mbedtls...
    cd "pico-keys-sdk\mbedtls"
    git fetch origin
    git checkout v3.6.5
    cd /d "%PROJECT_ROOT%"
)

if exist build rd /s /q build
mkdir build
cd build

set "PICO_SDK_PATH=%PROJECT_ROOT%\pico-sdk"

echo [INFO] CMake Configure Firmware...
cmake -G Ninja .. ^
    -DPICO_BOARD=waveshare_rp2040_zero ^
    -DVIDPID=Yubikey5

echo [INFO] Ninja Build Firmware...
ninja

echo.
echo [DONE] Build complete!
pause