Write-Host "================================================" -ForegroundColor Cyan
Write-Host "Backend-AI Integration Test" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Test 1: Check AI API Health..." -ForegroundColor Yellow
$health = curl.exe -s http://localhost:8000/health | ConvertFrom-Json
Write-Host "Status: $($health.status)" -ForegroundColor Green
Write-Host "Model Loaded: $($health.model_loaded)" -ForegroundColor Green
Write-Host ""

Write-Host "Test 2: Test AI Prediction..." -ForegroundColor Yellow
$data = '{"numFloors":10,"floorHeight":3.5,"numBeams":120,"numColumns":36,"beamSection":30.0,"columnSection":40.0,"concreteStrength":35.0,"steelGrade":355.0,"windLoad":1.5,"liveLoad":3.0,"deadLoad":5.0}'
$result = curl.exe -s -X POST http://localhost:8000/predict -H "Content-Type: application/json" -d $data | ConvertFrom-Json

Write-Host "Max Deflection: $($result.maxDeflection) mm" -ForegroundColor White
Write-Host "Max Stress: $($result.maxStress) MPa" -ForegroundColor White
Write-Host "Stability Index: $($result.stabilityIndex)%" -ForegroundColor White
Write-Host "Seismic Resistance: $($result.seismicResistance)%" -ForegroundColor White
Write-Host "Status: $($result.status)" -ForegroundColor Green
Write-Host ""

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "Phase 1 Integration Complete!" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Cyan
