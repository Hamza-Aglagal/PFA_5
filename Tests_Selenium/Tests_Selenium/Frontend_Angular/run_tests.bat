@echo off
REM Script pour exécuter les tests Selenium Frontend
REM Auteur: SimStruct Team
REM Date: 25/12/2025

echo ========================================
echo   Tests Selenium - Frontend Angular
echo ========================================
echo.

REM Vérifier que Maven est installé
where mvn >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERREUR] Maven n'est pas installé ou pas dans le PATH
    echo Installez Maven depuis: https://maven.apache.org/download.cgi
    pause
    exit /b 1
)

echo [INFO] Maven detecte: OK
echo.

REM Vérifier que Java est installé
where java >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERREUR] Java n'est pas installé ou pas dans le PATH
    echo Installez Java 17+ depuis: https://adoptium.net/
    pause
    exit /b 1
)

echo [INFO] Java detecte: OK
java -version
echo.

REM Vérifier que l'application Angular tourne
echo [INFO] Verification que l'application Angular est demarree...
powershell -Command "try { Invoke-WebRequest -Uri 'http://localhost:4200' -UseBasicParsing -TimeoutSec 2 | Out-Null; exit 0 } catch { exit 1 }"
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo [ATTENTION] L'application Angular ne semble pas demarree sur le port 4200
    echo.
    echo Demarrez l'application dans un autre terminal:
    echo   cd c:\Users\PC\PFA_5\PFA_5\Web\simstruct
    echo   npm start
    echo.
    set /p CONTINUE="Voulez-vous continuer quand meme? (o/n): "
    if /i not "%CONTINUE%"=="o" (
        echo Tests annules.
        pause
        exit /b 1
    )
) else (
    echo [INFO] Application Angular detectee sur http://localhost:4200
)

echo.
echo ========================================
echo   Execution des tests
echo ========================================
echo.

REM Exécuter les tests
echo [INFO] Execution de: mvn clean test
echo.

mvn clean test

REM Vérifier le résultat
if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo   SUCCES - Tous les tests sont passes!
    echo ========================================
    echo.
    echo [INFO] Screenshots disponibles dans: target\screenshots
    echo [INFO] Rapport HTML disponible dans: target\surefire-reports
    echo.
    
    REM Demander si on veut voir les screenshots
    set /p SHOW_SCREENSHOTS="Voulez-vous ouvrir le dossier des screenshots? (o/n): "
    if /i "%SHOW_SCREENSHOTS%"=="o" (
        if exist "target\screenshots" (
            explorer target\screenshots
        ) else (
            echo [INFO] Aucun screenshot genere
        )
    )
    
    REM Demander si on veut générer le rapport HTML
    set /p GEN_REPORT="Voulez-vous generer le rapport HTML? (o/n): "
    if /i "%GEN_REPORT%"=="o" (
        echo.
        echo [INFO] Generation du rapport HTML...
        mvn surefire-report:report
        if exist "target\site\surefire-report.html" (
            explorer target\site\surefire-report.html
        )
    )
    
) else (
    echo.
    echo ========================================
    echo   ECHEC - Certains tests ont echoue
    echo ========================================
    echo.
    echo [INFO] Consultez les logs ci-dessus pour plus de details
    echo [INFO] Screenshots d'erreur disponibles dans: target\screenshots
    echo.
)

echo.
pause
