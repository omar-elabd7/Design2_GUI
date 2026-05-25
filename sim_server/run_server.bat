@echo off
echo ============================================
echo   Robot Simulation Server — localhost:8000
echo ============================================
echo.

:: Check Python
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Python not found. Install Python 3.10+ first.
    pause
    exit /b 1
)

:: Install deps if needed
echo [1/2] Installing dependencies...
pip install -r requirements.txt --quiet

echo [2/2] Starting server...
echo.
echo   Dashboard  :  http://localhost:8000
echo   Flutter WS :  ws://localhost:8000/ws
echo   Flutter API:  http://localhost:8000
echo.
echo Press Ctrl+C to stop.
echo.

python sim_server.py
pause
