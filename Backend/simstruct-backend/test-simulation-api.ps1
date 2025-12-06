# SIMSTRUCT - Simulation API Test Script
# Run this after starting the backend server

$BaseUrl = "http://localhost:8080/api/v1"
$TestResults = @()

function Write-TestResult($TestName, $Passed, $Message) {
    $status = if ($Passed) { "PASS" } else { "FAIL" }
    $color = if ($Passed) { "Green" } else { "Red" }
    Write-Host "[$status] $TestName - $Message" -ForegroundColor $color
    $script:TestResults += @{ Name = $TestName; Passed = $Passed; Message = $Message }
}

function Invoke-ApiRequest($Method, $Endpoint, $Body = $null, $Token = $null) {
    $headers = @{ "Content-Type" = "application/json" }
    if ($Token) { $headers["Authorization"] = "Bearer $Token" }
    
    $params = @{
        Method = $Method
        Uri = "$BaseUrl$Endpoint"
        Headers = $headers
        ContentType = "application/json"
    }
    
    if ($Body) { $params["Body"] = ($Body | ConvertTo-Json -Depth 10) }
    
    try {
        $response = Invoke-RestMethod @params -ErrorAction Stop
        return @{ Success = $true; Data = $response }
    } catch {
        $errorMsg = $_.Exception.Message
        if ($_.Exception.Response) {
            try {
                $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
                $errorMsg = $reader.ReadToEnd()
            } catch {}
        }
        return @{ Success = $false; Error = $errorMsg }
    }
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "   SIMSTRUCT SIMULATION API TEST" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# -------------------------------------------
# TEST 1: Register a test user
# -------------------------------------------
Write-Host "Setting up test user..." -ForegroundColor Yellow
$timestamp = Get-Date -Format "yyyyMMddHHmmss"
$testEmail = "simtest_$timestamp@test.com"
$testPassword = "Test123!"

$registerBody = @{
    firstName = "Sim"
    lastName = "Tester"
    email = $testEmail
    password = $testPassword
}

$registerResult = Invoke-ApiRequest -Method "POST" -Endpoint "/auth/register" -Body $registerBody

if ($registerResult.Success) {
    Write-TestResult "User Registration" $true "User registered: $testEmail"
    $authToken = $registerResult.Data.token
} else {
    Write-TestResult "User Registration" $false $registerResult.Error
    Write-Host "`nCannot continue without auth. Exiting." -ForegroundColor Red
    exit
}

# -------------------------------------------
# TEST 2: Create a simulation
# -------------------------------------------
Write-Host "`n--- Testing Simulation Create ---" -ForegroundColor Yellow

$simulationBody = @{
    name = "Steel Beam Test"
    description = "Test simulation for API verification"
    beamLength = 5.0
    beamWidth = 0.3
    beamHeight = 0.5
    materialType = "STEEL"
    elasticModulus = 200000000000
    density = 7850
    yieldStrength = 250000000
    loadType = "POINT"
    loadMagnitude = 10000
    loadPosition = 2.5
    supportType = "SIMPLY_SUPPORTED"
    isPublic = $false
}

$createResult = Invoke-ApiRequest -Method "POST" -Endpoint "/simulations" -Body $simulationBody -Token $authToken

if ($createResult.Success) {
    $simulation = $createResult.Data
    Write-TestResult "Create Simulation" $true "ID: $($simulation.id), Status: $($simulation.status)"
    Write-Host "  - Max Deflection: $($simulation.results.maxDeflection) m" -ForegroundColor Gray
    Write-Host "  - Max Stress: $($simulation.results.maxStress) Pa" -ForegroundColor Gray
    Write-Host "  - Safety Factor: $($simulation.results.safetyFactor)" -ForegroundColor Gray
    Write-Host "  - Is Safe: $($simulation.results.isSafe)" -ForegroundColor Gray
    $simulationId = $simulation.id
} else {
    Write-TestResult "Create Simulation" $false $createResult.Error
    $simulationId = $null
}

# -------------------------------------------
# TEST 3: Get simulation by ID
# -------------------------------------------
if ($simulationId) {
    $getResult = Invoke-ApiRequest -Method "GET" -Endpoint "/simulations/$simulationId" -Token $authToken
    
    if ($getResult.Success) {
        Write-TestResult "Get Simulation by ID" $true "Retrieved: $($getResult.Data.name)"
    } else {
        Write-TestResult "Get Simulation by ID" $false $getResult.Error
    }
}

# -------------------------------------------
# TEST 4: Get all user simulations
# -------------------------------------------
$getAllResult = Invoke-ApiRequest -Method "GET" -Endpoint "/simulations" -Token $authToken

if ($getAllResult.Success) {
    $count = $getAllResult.Data.Count
    Write-TestResult "Get All Simulations" $true "Found $count simulation(s)"
} else {
    Write-TestResult "Get All Simulations" $false $getAllResult.Error
}

# -------------------------------------------
# TEST 5: Get recent simulations
# -------------------------------------------
$recentResult = Invoke-ApiRequest -Method "GET" -Endpoint "/simulations/recent" -Token $authToken

if ($recentResult.Success) {
    $count = $recentResult.Data.Count
    Write-TestResult "Get Recent Simulations" $true "Found $count recent simulation(s)"
} else {
    Write-TestResult "Get Recent Simulations" $false $recentResult.Error
}

# -------------------------------------------
# TEST 6: Toggle favorite
# -------------------------------------------
if ($simulationId) {
    $favResult = Invoke-ApiRequest -Method "POST" -Endpoint "/simulations/$simulationId/favorite" -Token $authToken
    
    if ($favResult.Success) {
        Write-TestResult "Toggle Favorite" $true "Favorite: $($favResult.Data.isFavorite)"
    } else {
        Write-TestResult "Toggle Favorite" $false $favResult.Error
    }
}

# -------------------------------------------
# TEST 7: Toggle public
# -------------------------------------------
if ($simulationId) {
    $pubResult = Invoke-ApiRequest -Method "POST" -Endpoint "/simulations/$simulationId/public" -Token $authToken
    
    if ($pubResult.Success) {
        Write-TestResult "Toggle Public" $true "Public: $($pubResult.Data.isPublic)"
    } else {
        Write-TestResult "Toggle Public" $false $pubResult.Error
    }
}

# -------------------------------------------
# TEST 8: Get public simulations
# -------------------------------------------
$publicResult = Invoke-ApiRequest -Method "GET" -Endpoint "/simulations/public"

if ($publicResult.Success) {
    $count = $publicResult.Data.Count
    Write-TestResult "Get Public Simulations" $true "Found $count public simulation(s)"
} else {
    Write-TestResult "Get Public Simulations" $false $publicResult.Error
}

# -------------------------------------------
# TEST 9: Search simulations
# -------------------------------------------
$searchResult = Invoke-ApiRequest -Method "GET" -Endpoint "/simulations/search?q=Steel" -Token $authToken

if ($searchResult.Success) {
    $count = $searchResult.Data.Count
    Write-TestResult "Search Simulations" $true "Found $count result(s) for 'Steel'"
} else {
    Write-TestResult "Search Simulations" $false $searchResult.Error
}

# -------------------------------------------
# TEST 10: Update simulation
# -------------------------------------------
if ($simulationId) {
    $updateBody = @{
        name = "Updated Steel Beam"
        description = "Updated description"
        beamLength = 6.0
        beamWidth = 0.35
        beamHeight = 0.55
        materialType = "STEEL"
        elasticModulus = 200000000000
        loadType = "POINT"
        loadMagnitude = 15000
        loadPosition = 3.0
        supportType = "SIMPLY_SUPPORTED"
        isPublic = $true
    }
    
    $updateResult = Invoke-ApiRequest -Method "PUT" -Endpoint "/simulations/$simulationId" -Body $updateBody -Token $authToken
    
    if ($updateResult.Success) {
        Write-TestResult "Update Simulation" $true "Updated: $($updateResult.Data.name)"
        Write-Host "  - New Safety Factor: $($updateResult.Data.results.safetyFactor)" -ForegroundColor Gray
    } else {
        Write-TestResult "Update Simulation" $false $updateResult.Error
    }
}

# -------------------------------------------
# TEST 11: Create simulation with different materials
# -------------------------------------------
Write-Host "`n--- Testing Different Materials ---" -ForegroundColor Yellow

$materials = @("CONCRETE", "ALUMINUM", "WOOD")
foreach ($material in $materials) {
    $matBody = @{
        name = "$material Beam Test"
        description = "Testing $material"
        beamLength = 4.0
        beamWidth = 0.4
        beamHeight = 0.6
        materialType = $material
        loadType = "POINT"
        loadMagnitude = 5000
        supportType = "SIMPLY_SUPPORTED"
        isPublic = $false
    }
    
    $matResult = Invoke-ApiRequest -Method "POST" -Endpoint "/simulations" -Body $matBody -Token $authToken
    
    if ($matResult.Success) {
        Write-TestResult "$material Simulation" $true "SF: $($matResult.Data.results.safetyFactor)"
    } else {
        Write-TestResult "$material Simulation" $false $matResult.Error
    }
}

# -------------------------------------------
# TEST 12: Test different support types
# -------------------------------------------
Write-Host "`n--- Testing Support Types ---" -ForegroundColor Yellow

$supports = @("FIXED_FREE", "FIXED_FIXED")
foreach ($support in $supports) {
    $supBody = @{
        name = "$support Test"
        description = "Testing $support"
        beamLength = 5.0
        beamWidth = 0.3
        beamHeight = 0.5
        materialType = "STEEL"
        loadType = "POINT"
        loadMagnitude = 10000
        supportType = $support
        isPublic = $false
    }
    
    $supResult = Invoke-ApiRequest -Method "POST" -Endpoint "/simulations" -Body $supBody -Token $authToken
    
    if ($supResult.Success) {
        Write-TestResult "$support Support" $true "Deflection: $($supResult.Data.results.maxDeflection) m"
    } else {
        Write-TestResult "$support Support" $false $supResult.Error
    }
}

# -------------------------------------------
# TEST 13: Delete simulation
# -------------------------------------------
if ($simulationId) {
    $deleteResult = Invoke-ApiRequest -Method "DELETE" -Endpoint "/simulations/$simulationId" -Token $authToken
    
    if ($deleteResult.Success) {
        Write-TestResult "Delete Simulation" $true "Deleted simulation $simulationId"
    } else {
        Write-TestResult "Delete Simulation" $false $deleteResult.Error
    }
}

# -------------------------------------------
# SUMMARY
# -------------------------------------------
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "           TEST SUMMARY" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$passed = ($TestResults | Where-Object { $_.Passed }).Count
$failed = ($TestResults | Where-Object { -not $_.Passed }).Count
$total = $TestResults.Count

Write-Host "`nTotal Tests: $total" -ForegroundColor White
Write-Host "Passed: $passed" -ForegroundColor Green
Write-Host "Failed: $failed" -ForegroundColor Red
Write-Host "Success Rate: $([math]::Round(($passed / $total) * 100, 1))%`n" -ForegroundColor $(if ($failed -eq 0) { "Green" } else { "Yellow" })

if ($failed -gt 0) {
    Write-Host "Failed Tests:" -ForegroundColor Red
    $TestResults | Where-Object { -not $_.Passed } | ForEach-Object {
        Write-Host "  - $($_.Name): $($_.Message)" -ForegroundColor Red
    }
}
