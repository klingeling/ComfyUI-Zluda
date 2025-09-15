@echo off

set "PYTHON=%~dp0venv\Scripts\python.exe"
set "GIT="
set "VENV_DIR=.\venv"

set "COMMANDLINE_ARGS=--auto-launch --use-quad-cross-attention --reserve-vram 0.9"

set "ZLUDA_COMGR_LOG_LEVEL=1"

:: Check Git version and installed commit hash
where git >NUL 2>&1
if errorlevel 1 (
    echo [FAIL] Git not found in PATH. Please install Git.
    pause
) else (
    for /f "tokens=3*" %%v in ('git --version') do (
        echo [INFO] Detected Git version: %%v %%w
    )
    for /f %%h in ('git rev-parse --short HEAD') do (
        echo [INFO] Current ComfyUI-ZLUDA commit hash: %%h
    )
)

echo [INFO] Checking and updating to a new version if possible...
copy comfy\customzluda\zluda-default.py comfy\zluda.py /y >NUL
git pull
copy comfy\customzluda\zluda-default.py comfy\zluda.py /y >NUL

:: Check for zluda.exe and nccl.dll inside the zluda folder
echo.
echo [INFO] Checking ZLUDA installation...
pushd .\zluda
if exist zluda.exe (
    if not exist nccl.dll (
        for /f "tokens=2 delims= " %%v in ('zluda.exe --version 2^>^&1') do (
            echo [FAIL] Detected version [%%v], but nccl.dll is missing. Likely blocked by AV as false positive.
        )
    ) else (
        for /f "tokens=2 delims= " %%v in ('zluda.exe --version 2^>^&1') do (
            echo [PASS] Detected version: %%v
        )
    )
) else (
    echo [FAIL] Can't detect zluda.exe inside .\zluda directory.
)
popd

echo [INFO] Launching application via ZLUDA...
echo.
.\zluda\zluda.exe -- %PYTHON% main.py %COMMANDLINE_ARGS%
pause

