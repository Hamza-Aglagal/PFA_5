@echo off
REM Script pour démarrer l'API FastAPI
echo ========================================
echo  Demarrage de l'API SimStruct AI
echo ========================================

cd /d "%~dp0"
call ..\venv\Scripts\activate.bat

echo.
echo Installation des dependances...
pip install fastapi uvicorn requests

echo.
echo Demarrage du serveur API...
echo L'API sera accessible sur: http://localhost:8000
echo Documentation: http://localhost:8000/docs
echo.
echo Appuyez sur Ctrl+C pour arreter le serveur
echo.

uvicorn api:app --reload --host 0.0.0.0 --port 8000
