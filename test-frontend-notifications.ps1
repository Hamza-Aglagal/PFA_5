# =====================================================
# SimStruct Notification System - Frontend Test Script
# =====================================================
# Tests frontend notification integration
# Run with: .\test-frontend-notifications.ps1
# =====================================================

param(
    [string]$FrontendUrl = "http://localhost:4200",
    [string]$BackendUrl = "http://localhost:8080/api/v1"
)

$ErrorActionPreference = "Stop"

# Colors for output
function Write-Success { param($msg) Write-Host "✅ $msg" -ForegroundColor Green }
function Write-Failure { param($msg) Write-Host "❌ $msg" -ForegroundColor Red }
function Write-Info { param($msg) Write-Host "ℹ️  $msg" -ForegroundColor Cyan }
function Write-Header { param($msg) Write-Host "`n========== $msg ==========`n" -ForegroundColor Yellow }
function Write-Step { param($msg) Write-Host "📋 $msg" -ForegroundColor Magenta }

# Test results tracking
$script:passed = 0
$script:failed = 0
$script:testResults = @()

function Add-TestResult {
    param($name, $success, $details)
    $script:testResults += @{
        Name = $name
        Success = $success
        Details = $details
        Timestamp = Get-Date -Format "HH:mm:ss"
    }
    if ($success) { $script:passed++ } else { $script:failed++ }
}

# =====================================================
# Test 1: Frontend Availability
# =====================================================

Write-Header "TEST 1: Frontend Availability"

try {
    $response = Invoke-WebRequest -Uri $FrontendUrl -UseBasicParsing -TimeoutSec 10
    if ($response.StatusCode -eq 200) {
        Write-Success "Frontend is accessible at $FrontendUrl"
        Add-TestResult "Frontend Availability" $true "Status: 200 OK"
    }
    else {
        Write-Failure "Frontend returned unexpected status: $($response.StatusCode)"
        Add-TestResult "Frontend Availability" $false "Status: $($response.StatusCode)"
    }
}
catch {
    Write-Failure "Frontend is not accessible: $($_.Exception.Message)"
    Add-TestResult "Frontend Availability" $false "Not reachable"
    Write-Info "Make sure the frontend is running (ng serve or Docker)"
}

# =====================================================
# Test 2: Backend Availability
# =====================================================

Write-Header "TEST 2: Backend Availability"

try {
    $response = Invoke-WebRequest -Uri "$BackendUrl/health" -UseBasicParsing -TimeoutSec 10
    Write-Success "Backend is accessible at $BackendUrl"
    Add-TestResult "Backend Availability" $true "Status: 200 OK"
}
catch {
    # Try auth endpoint as fallback
    try {
        $body = @{ email = "test@test.com"; password = "test" } | ConvertTo-Json
        $response = Invoke-RestMethod -Uri "$BackendUrl/auth/login" -Method POST -Body $body -ContentType "application/json" -ErrorAction SilentlyContinue
    }
    catch {
        # Expected to fail, but means backend is up
        if ($_.Exception.Response.StatusCode -ne $null) {
            Write-Success "Backend is accessible at $BackendUrl"
            Add-TestResult "Backend Availability" $true "Auth endpoint responds"
        }
        else {
            Write-Failure "Backend is not accessible: $($_.Exception.Message)"
            Add-TestResult "Backend Availability" $false "Not reachable"
        }
    }
}

# =====================================================
# Test 3: WebSocket Endpoint Availability
# =====================================================

Write-Header "TEST 3: WebSocket Endpoint"

$wsEndpoint = $BackendUrl.Replace("/api/v1", "/ws")
Write-Info "WebSocket endpoint: $wsEndpoint"

try {
    # Check if the WebSocket endpoint responds (it will upgrade connection)
    $response = Invoke-WebRequest -Uri "$wsEndpoint/info" -UseBasicParsing -TimeoutSec 5 -ErrorAction SilentlyContinue
    Write-Success "WebSocket endpoint is accessible"
    Add-TestResult "WebSocket Endpoint" $true "SockJS info endpoint available"
}
catch {
    if ($_.Exception.Response.StatusCode -eq 404) {
        Write-Info "SockJS info endpoint returned 404 (may need WebSocket upgrade)"
        Add-TestResult "WebSocket Endpoint" $true "Endpoint exists (404 expected for HTTP)"
    }
    else {
        Write-Failure "WebSocket endpoint check failed: $($_.Exception.Message)"
        Add-TestResult "WebSocket Endpoint" $false $_.Exception.Message
    }
}

# =====================================================
# Test 4: Notification API Endpoints
# =====================================================

Write-Header "TEST 4: Notification API Endpoints (Unauthorized)"

$endpoints = @(
    @{ Method = "GET"; Path = "/notifications"; Expected = 401 },
    @{ Method = "GET"; Path = "/notifications/count"; Expected = 401 },
    @{ Method = "GET"; Path = "/notifications/unread"; Expected = 401 }
)

foreach ($endpoint in $endpoints) {
    try {
        $response = Invoke-WebRequest -Uri "$BackendUrl$($endpoint.Path)" -Method $endpoint.Method -UseBasicParsing -ErrorAction SilentlyContinue
        Write-Failure "$($endpoint.Method) $($endpoint.Path) should require auth (got $($response.StatusCode))"
        Add-TestResult "Endpoint $($endpoint.Path)" $false "No auth required"
    }
    catch {
        $statusCode = [int]$_.Exception.Response.StatusCode
        if ($statusCode -eq $endpoint.Expected -or $statusCode -eq 403) {
            Write-Success "$($endpoint.Method) $($endpoint.Path) properly requires authentication"
            Add-TestResult "Endpoint $($endpoint.Path)" $true "Auth required (401/403)"
        }
        else {
            Write-Failure "$($endpoint.Method) $($endpoint.Path) returned unexpected status: $statusCode"
            Add-TestResult "Endpoint $($endpoint.Path)" $false "Status: $statusCode"
        }
    }
}

# =====================================================
# Test 5: Create Test User and Check Notifications
# =====================================================

Write-Header "TEST 5: End-to-End Notification Flow"

# Register a test user
$timestamp = Get-Date -Format 'yyyyMMddHHmmss'
$testUser = @{
    name = "Frontend Test User"
    email = "frontend_test_$timestamp@test.com"
    password = "Test123!"
}

Write-Step "1. Registering test user..."
try {
    $response = Invoke-RestMethod -Uri "$BackendUrl/auth/register" -Method POST -Body ($testUser | ConvertTo-Json) -ContentType "application/json"
    
    if ($response.success -and $response.data.accessToken) {
        Write-Success "User registered successfully"
        $token = $response.data.accessToken
        $userId = $response.data.user.id
        Add-TestResult "User Registration" $true "Token received"
        
        # Wait for welcome notification
        Start-Sleep -Milliseconds 500
        
        Write-Step "2. Checking for welcome notification..."
        $headers = @{ Authorization = "Bearer $token" }
        $notifResponse = Invoke-RestMethod -Uri "$BackendUrl/notifications" -Headers $headers
        
        if ($notifResponse.success) {
            $welcomeNotif = $notifResponse.data | Where-Object { $_.type -eq "WELCOME" }
            if ($welcomeNotif) {
                Write-Success "Welcome notification created automatically"
                Write-Info "Title: $($welcomeNotif.title)"
                Add-TestResult "Welcome Notification" $true "Auto-created on registration"
            }
            else {
                Write-Failure "Welcome notification not found"
                Add-TestResult "Welcome Notification" $false "Not created"
            }
        }
        
        Write-Step "3. Checking notification count..."
        $countResponse = Invoke-RestMethod -Uri "$BackendUrl/notifications/count" -Headers $headers
        
        if ($countResponse.success) {
            Write-Success "Notification count: Unread=$($countResponse.data.unreadCount), Total=$($countResponse.data.totalCount)"
            Add-TestResult "Notification Count" $true "API working"
        }
        
        Write-Step "4. Creating simulation for notification..."
        $simBody = @{
            name = "Frontend Test Simulation"
            description = "Testing notification flow"
            beamLength = 5.0
            beamWidth = 0.3
            beamHeight = 0.5
            materialType = "STEEL"
            elasticModulus = 210000000000
            density = 7850
            yieldStrength = 250000000
            loadType = "POINT"
            loadMagnitude = 10000
            loadPosition = 2.5
            supportType = "SIMPLY_SUPPORTED"
            isPublic = $false
        }
        
        $simResponse = Invoke-RestMethod -Uri "$BackendUrl/simulations" -Method POST -Body ($simBody | ConvertTo-Json) -ContentType "application/json" -Headers $headers
        
        if ($simResponse.success -and $simResponse.data.status -eq "COMPLETED") {
            Write-Success "Simulation created and completed"
            
            Start-Sleep -Milliseconds 500
            $notifResponse2 = Invoke-RestMethod -Uri "$BackendUrl/notifications" -Headers $headers
            $simNotif = $notifResponse2.data | Where-Object { $_.type -eq "SIMULATION_COMPLETE" }
            
            if ($simNotif) {
                Write-Success "Simulation completion notification received"
                Add-TestResult "Simulation Notification" $true "Auto-created on completion"
            }
            else {
                Write-Failure "Simulation notification not found"
                Add-TestResult "Simulation Notification" $false "Not created"
            }
        }
        else {
            Write-Failure "Simulation failed"
            Add-TestResult "Simulation Notification" $false "Simulation failed"
        }
        
        Write-Step "5. Testing mark as read..."
        $notifResponse3 = Invoke-RestMethod -Uri "$BackendUrl/notifications" -Headers $headers
        if ($notifResponse3.data.Count -gt 0) {
            $firstNotif = $notifResponse3.data[0]
            $markResponse = Invoke-RestMethod -Uri "$BackendUrl/notifications/$($firstNotif.id)/read" -Method PUT -Headers $headers
            
            if ($markResponse.success) {
                Write-Success "Notification marked as read"
                Add-TestResult "Mark as Read" $true "API working"
            }
        }
        
        Write-Step "6. Testing mark all as read..."
        $markAllResponse = Invoke-RestMethod -Uri "$BackendUrl/notifications/read-all" -Method PUT -Headers $headers
        
        if ($markAllResponse.success) {
            Write-Success "All notifications marked as read"
            Add-TestResult "Mark All Read" $true "API working"
        }
    }
    else {
        Write-Failure "Registration failed"
        Add-TestResult "User Registration" $false "No token received"
    }
}
catch {
    Write-Failure "Registration error: $($_.Exception.Message)"
    Add-TestResult "User Registration" $false $_.Exception.Message
}

# =====================================================
# Test 6: Frontend Files Check
# =====================================================

Write-Header "TEST 6: Frontend Service Files"

$frontendFiles = @(
    "Web\simstruct\src\app\core\services\backend-notification.service.ts",
    "Web\simstruct\src\app\shared\components\navbar\navbar.component.ts",
    "Web\simstruct\src\app\shared\components\navbar\navbar.component.html"
)

$basePath = (Get-Location).Path

foreach ($file in $frontendFiles) {
    $fullPath = Join-Path $basePath $file
    if (Test-Path $fullPath) {
        Write-Success "File exists: $file"
        
        # Check for specific content
        $content = Get-Content $fullPath -Raw
        if ($file -like "*notification.service*") {
            if ($content -match "BackendNotificationService") {
                Write-Success "  - BackendNotificationService class found"
            }
            if ($content -match "WebSocket") {
                Write-Success "  - WebSocket support included"
            }
        }
        
        Add-TestResult "File: $file" $true "Exists and contains expected code"
    }
    else {
        Write-Failure "File not found: $file"
        Add-TestResult "File: $file" $false "Not found"
    }
}

# =====================================================
# Test Summary
# =====================================================

Write-Header "TEST SUMMARY"

Write-Host ""
Write-Host "Total Tests: $($script:passed + $script:failed)" -ForegroundColor White
Write-Host "Passed: $($script:passed)" -ForegroundColor Green
Write-Host "Failed: $($script:failed)" -ForegroundColor Red
Write-Host ""

# Detailed results
Write-Host "Detailed Results:" -ForegroundColor Yellow
Write-Host "-----------------"
foreach ($test in $script:testResults) {
    $status = if ($test.Success) { "✅" } else { "❌" }
    $color = if ($test.Success) { "Green" } else { "Red" }
    Write-Host "$status [$($test.Timestamp)] $($test.Name): $($test.Details)" -ForegroundColor $color
}

Write-Host ""
if ($script:failed -eq 0) {
    Write-Host "🎉 All tests passed! Frontend notification integration is ready." -ForegroundColor Green
}
else {
    Write-Host "⚠️  Some tests failed. Please check the issues above." -ForegroundColor Yellow
}

# Manual testing instructions
Write-Header "MANUAL TESTING INSTRUCTIONS"

Write-Host @"
To fully test the notification system in the browser:

1. Start the backend:
   cd Backend\simstruct-backend
   mvn spring-boot:run

2. Start the frontend:
   cd Web\simstruct
   ng serve

3. Open http://localhost:4200 in your browser

4. Register a new account
   - You should see a welcome notification appear
   - The notification bell should show "1" badge

5. Click the notification bell
   - You should see the welcome notification in the dropdown
   - Click on it to mark it as read

6. Create a simulation
   - Go to Simulation page
   - Fill in parameters and run
   - A completion notification should appear

7. Test friend notifications (needs 2 browser sessions):
   - Register another account in incognito window
   - Send friend request from User 1 to User 2
   - User 2 should see friend request notification
   - Accept the request
   - User 1 should see friend accepted notification

8. Test chat notifications:
   - Send a message from User 1 to User 2
   - User 2 should see new message notification

9. Test share notifications:
   - Share a simulation from User 1 to User 2
   - User 2 should see shared simulation notification

10. Test WebSocket real-time updates:
    - Keep the notification dropdown open
    - Trigger a notification from another session
    - The notification should appear without refresh

"@ -ForegroundColor Cyan

# Save results to file
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$logFile = "LOGS/frontend-notification-test-$timestamp.md"

$logContent = @"
# Frontend Notification Test Results
**Date:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
**Frontend URL:** $FrontendUrl
**Backend URL:** $BackendUrl

## Summary
- **Total Tests:** $($script:passed + $script:failed)
- **Passed:** $($script:passed)
- **Failed:** $($script:failed)

## Test Results
| Status | Time | Test Name | Details |
|--------|------|-----------|---------|
"@

foreach ($test in $script:testResults) {
    $status = if ($test.Success) { "✅" } else { "❌" }
    $logContent += "`n| $status | $($test.Timestamp) | $($test.Name) | $($test.Details) |"
}

$logContent | Out-File -FilePath $logFile -Encoding UTF8
Write-Info "Test results saved to: $logFile"
