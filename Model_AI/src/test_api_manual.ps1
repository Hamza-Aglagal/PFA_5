# Script PowerShell pour tester l'API manuellement
# Utilisez ce script pour tester si l'API fonctionne

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Test manuel de l'API SimStruct AI" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# URL de l'API
$apiUrl = "http://localhost:8000"

# Données de test pour un bâtiment
$buildingData = @{
    numFloors = 10
    floorHeight = 3.5
    numBeams = 120
    numColumns = 36
    beamSection = 30
    columnSection = 40
    concreteStrength = 35
    steelGrade = 355
    windLoad = 1.5
    liveLoad = 3.0
    deadLoad = 5.0
} | ConvertTo-Json

Write-Host "Test 1: Verification de la sante de l'API" -ForegroundColor Yellow
Write-Host "URL: $apiUrl/health" -ForegroundColor Gray
try {
    $response = Invoke-RestMethod -Uri "$apiUrl/health" -Method Get
    Write-Host "Resultat:" -ForegroundColor Green
    $response | ConvertTo-Json -Depth 3
    Write-Host ""
} catch {
    Write-Host "Erreur: L'API n'est pas accessible." -ForegroundColor Red
    Write-Host "Assurez-vous de demarrer l'API avec: start_api.bat" -ForegroundColor Red
    Write-Host ""
    exit
}

Write-Host "Test 2: Information sur le modele" -ForegroundColor Yellow
Write-Host "URL: $apiUrl/model-info" -ForegroundColor Gray
try {
    $response = Invoke-RestMethod -Uri "$apiUrl/model-info" -Method Get
    Write-Host "Resultat:" -ForegroundColor Green
    $response | ConvertTo-Json -Depth 3
    Write-Host ""
} catch {
    Write-Host "Erreur lors de la recuperation des infos." -ForegroundColor Red
    Write-Host ""
}

Write-Host "Test 3: Prediction pour un batiment" -ForegroundColor Yellow
Write-Host "URL: $apiUrl/predict" -ForegroundColor Gray
Write-Host "Donnees envoyees:" -ForegroundColor Gray
Write-Host $buildingData -ForegroundColor Gray
try {
    $response = Invoke-RestMethod -Uri "$apiUrl/predict" -Method Post -Body $buildingData -ContentType "application/json"
    Write-Host "Resultat de la prediction:" -ForegroundColor Green
    Write-Host "  Deflexion maximale:      $($response.maxDeflection) mm" -ForegroundColor White
    Write-Host "  Contrainte maximale:     $($response.maxStress) MPa" -ForegroundColor White
    Write-Host "  Indice de stabilite:     $($response.stabilityIndex)" -ForegroundColor White
    Write-Host "  Resistance sismique:     $($response.seismicResistance)" -ForegroundColor White
    Write-Host "  Statut:                  $($response.status)" -ForegroundColor White
    Write-Host ""
} catch {
    Write-Host "Erreur lors de la prediction." -ForegroundColor Red
    Write-Host ""
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Tests termines!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
