@echo off
REM Script pour tester l'API
echo ========================================
echo  Test de l'API SimStruct AI
echo ========================================

cd /d "%~dp0"
call ..\venv\Scripts\activate.bat

echo.
echo Lancement des tests...
echo.

python test_api.py

echo.
echo ========================================
echo  Tests termines!
echo ========================================
pause
