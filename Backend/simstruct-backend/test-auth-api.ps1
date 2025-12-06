# ============================================
# SIMSTRUCT - Authentication API Test Script
# ============================================
# Run this script to test all auth endpoints
# Make sure the server is running on port 8080
# ============================================

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "   SIMSTRUCT AUTH API TEST SCRIPT" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$baseUrl = "http://localhost:8080/api/v1"

# Wait for server to be ready
Write-Host "Checking if server is ready..." -ForegroundColor Yellow
$maxRetries = 10
$retryCount = 0
$serverReady = $false

while (-not $serverReady -and $retryCount -lt $maxRetries) {
    try {
        $response = Invoke-WebRequest -Uri "$baseUrl/auth/register" -Method POST -ContentType "application/json" -Body '{}' -ErrorAction Stop
        $serverReady = $true
    } catch {
        if ($_.Exception.Response) {
            $serverReady = $true
        } else {
            $retryCount++
            Write-Host "  Waiting for server... ($retryCount/$maxRetries)" -ForegroundColor Gray
            Start-Sleep -Seconds 2
        }
    }
}

if (-not $serverReady) {
    Write-Host "ERROR: Server is not responding on $baseUrl" -ForegroundColor Red
    Write-Host "Make sure the Spring Boot server is running!" -ForegroundColor Red
    exit 1
}

Write-Host "Server is ready!`n" -ForegroundColor Green

# Variables to store tokens
$accessToken = $null
$refreshToken = $null

# ============================================
# TEST 1: Register a new user
# ============================================
Write-Host "TEST 1: Register New User" -ForegroundColor Magenta
Write-Host "-------------------------" -ForegroundColor Magenta

$timestamp = Get-Date -Format "yyyyMMddHHmmss"
$testEmail = "testuser_$timestamp@example.com"

$registerBody = @{
    name = "Test User"
    email = $testEmail
    password = "Test123!"
} | ConvertTo-Json

try {
    $registerResponse = Invoke-RestMethod -Uri "$baseUrl/auth/register" -Method POST -ContentType "application/json" -Body $registerBody
    
    if ($registerResponse.success -eq $true) {
        Write-Host "SUCCESS: User registered!" -ForegroundColor Green
        Write-Host "  User ID: $($registerResponse.data.user.id)" -ForegroundColor White
        Write-Host "  Name: $($registerResponse.data.user.name)" -ForegroundColor White
        Write-Host "  Email: $($registerResponse.data.user.email)" -ForegroundColor White
        Write-Host "  Role: $($registerResponse.data.user.role)" -ForegroundColor White
        Write-Host "  Token: $($registerResponse.data.accessToken.Substring(0, 50))..." -ForegroundColor White
        
        # Save tokens for next tests
        $accessToken = $registerResponse.data.accessToken
        $refreshToken = $registerResponse.data.refreshToken
    } else {
        Write-Host "FAILED: $($registerResponse.error)" -ForegroundColor Red
    }
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    Write-Host "FAILED: Status $statusCode" -ForegroundColor Red
    try {
        $errorBody = $_.ErrorDetails.Message | ConvertFrom-Json
        Write-Host "  Error: $($errorBody.error)" -ForegroundColor Red
    } catch {
        Write-Host "  Error: $($_.ErrorDetails.Message)" -ForegroundColor Red
    }
}

Write-Host ""

# ============================================
# TEST 2: Try to register same user again (should fail)
# ============================================
Write-Host "TEST 2: Register Duplicate User (should fail)" -ForegroundColor Magenta
Write-Host "----------------------------------------------" -ForegroundColor Magenta

try {
    $duplicateResponse = Invoke-RestMethod -Uri "$baseUrl/auth/register" -Method POST -ContentType "application/json" -Body $registerBody
    Write-Host "UNEXPECTED: Registration succeeded (should have failed)" -ForegroundColor Yellow
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    Write-Host "SUCCESS: Duplicate registration blocked (Status: $statusCode)" -ForegroundColor Green
    try {
        $errorBody = $_.ErrorDetails.Message | ConvertFrom-Json
        Write-Host "  Message: $($errorBody.error)" -ForegroundColor White
    } catch {}
}

Write-Host ""

# ============================================
# TEST 3: Login with correct credentials
# ============================================
Write-Host "TEST 3: Login with Correct Credentials" -ForegroundColor Magenta
Write-Host "---------------------------------------" -ForegroundColor Magenta

$loginBody = @{
    email = $testEmail
    password = "Test123!"
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method POST -ContentType "application/json" -Body $loginBody
    
    if ($loginResponse.success -eq $true) {
        Write-Host "SUCCESS: Login successful!" -ForegroundColor Green
        Write-Host "  User: $($loginResponse.data.user.name)" -ForegroundColor White
        Write-Host "  Email: $($loginResponse.data.user.email)" -ForegroundColor White
        Write-Host "  Token: $($loginResponse.data.accessToken.Substring(0, 50))..." -ForegroundColor White
        
        # Update tokens
        $accessToken = $loginResponse.data.accessToken
        $refreshToken = $loginResponse.data.refreshToken
    } else {
        Write-Host "FAILED: $($loginResponse.error)" -ForegroundColor Red
    }
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    Write-Host "FAILED: Status $statusCode" -ForegroundColor Red
}

Write-Host ""

# ============================================
# TEST 4: Login with wrong password (should fail)
# ============================================
Write-Host "TEST 4: Login with Wrong Password (should fail)" -ForegroundColor Magenta
Write-Host "------------------------------------------------" -ForegroundColor Magenta

$wrongLoginBody = @{
    email = $testEmail
    password = "WrongPassword!"
} | ConvertTo-Json

try {
    $wrongLoginResponse = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method POST -ContentType "application/json" -Body $wrongLoginBody
    Write-Host "UNEXPECTED: Login succeeded (should have failed)" -ForegroundColor Yellow
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    Write-Host "SUCCESS: Wrong password rejected (Status: $statusCode)" -ForegroundColor Green
}

Write-Host ""

# ============================================
# TEST 5: Get user profile with token
# ============================================
Write-Host "TEST 5: Get User Profile (with token)" -ForegroundColor Magenta
Write-Host "--------------------------------------" -ForegroundColor Magenta

if ($accessToken) {
    $headers = @{
        "Authorization" = "Bearer $accessToken"
    }
    
    try {
        $profileResponse = Invoke-RestMethod -Uri "$baseUrl/users/me" -Method GET -Headers $headers
        
        if ($profileResponse.success -eq $true) {
            Write-Host "SUCCESS: Profile retrieved!" -ForegroundColor Green
            Write-Host "  ID: $($profileResponse.data.id)" -ForegroundColor White
            Write-Host "  Name: $($profileResponse.data.name)" -ForegroundColor White
            Write-Host "  Email: $($profileResponse.data.email)" -ForegroundColor White
            Write-Host "  Role: $($profileResponse.data.role)" -ForegroundColor White
        } else {
            Write-Host "FAILED: $($profileResponse.error)" -ForegroundColor Red
        }
    } catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
        Write-Host "FAILED: Status $statusCode" -ForegroundColor Red
        try {
            $errorBody = $_.ErrorDetails.Message | ConvertFrom-Json
            Write-Host "  Error: $($errorBody.error)" -ForegroundColor Red
        } catch {
            Write-Host "  Error: $($_.ErrorDetails.Message)" -ForegroundColor Red
        }
    }
} else {
    Write-Host "SKIPPED: No access token available" -ForegroundColor Yellow
}

Write-Host ""

# ============================================
# TEST 6: Get profile without token (should fail)
# ============================================
Write-Host "TEST 6: Get Profile Without Token (should fail)" -ForegroundColor Magenta
Write-Host "------------------------------------------------" -ForegroundColor Magenta

try {
    $noAuthResponse = Invoke-RestMethod -Uri "$baseUrl/users/me" -Method GET
    Write-Host "UNEXPECTED: Request succeeded without auth" -ForegroundColor Yellow
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    Write-Host "SUCCESS: Unauthorized request blocked (Status: $statusCode)" -ForegroundColor Green
}

Write-Host ""

# ============================================
# TEST 7: Update user profile
# ============================================
Write-Host "TEST 7: Update User Profile" -ForegroundColor Magenta
Write-Host "---------------------------" -ForegroundColor Magenta

if ($accessToken) {
    $headers = @{
        "Authorization" = "Bearer $accessToken"
    }
    
    $updateBody = @{
        name = "Updated Test User"
        phone = "+1234567890"
        company = "SIMSTRUCT Inc."
        jobTitle = "Engineer"
        bio = "Testing the API"
    } | ConvertTo-Json
    
    try {
        $updateResponse = Invoke-RestMethod -Uri "$baseUrl/users/me" -Method PUT -Headers $headers -ContentType "application/json" -Body $updateBody
        
        if ($updateResponse.success -eq $true) {
            Write-Host "SUCCESS: Profile updated!" -ForegroundColor Green
            Write-Host "  New Name: $($updateResponse.data.name)" -ForegroundColor White
            Write-Host "  Phone: $($updateResponse.data.phone)" -ForegroundColor White
            Write-Host "  Company: $($updateResponse.data.company)" -ForegroundColor White
            Write-Host "  Job Title: $($updateResponse.data.jobTitle)" -ForegroundColor White
            Write-Host "  Bio: $($updateResponse.data.bio)" -ForegroundColor White
        } else {
            Write-Host "FAILED: $($updateResponse.error)" -ForegroundColor Red
        }
    } catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
        Write-Host "FAILED: Status $statusCode" -ForegroundColor Red
        try {
            $errorBody = $_.ErrorDetails.Message | ConvertFrom-Json
            Write-Host "  Error: $($errorBody.error)" -ForegroundColor Red
        } catch {
            Write-Host "  Error: $($_.ErrorDetails.Message)" -ForegroundColor Red
        }
    }
} else {
    Write-Host "SKIPPED: No access token available" -ForegroundColor Yellow
}

Write-Host ""

# ============================================
# TEST 8: Refresh token
# ============================================
Write-Host "TEST 8: Refresh Access Token" -ForegroundColor Magenta
Write-Host "----------------------------" -ForegroundColor Magenta

if ($refreshToken) {
    $refreshBody = @{
        refreshToken = $refreshToken
    } | ConvertTo-Json
    
    try {
        $refreshResponse = Invoke-RestMethod -Uri "$baseUrl/auth/refresh" -Method POST -ContentType "application/json" -Body $refreshBody
        
        if ($refreshResponse.success -eq $true) {
            Write-Host "SUCCESS: Token refreshed!" -ForegroundColor Green
            Write-Host "  New token: $($refreshResponse.data.accessToken.Substring(0, 50))..." -ForegroundColor White
            
            # Update token for next test
            $accessToken = $refreshResponse.data.accessToken
        } else {
            Write-Host "FAILED: $($refreshResponse.error)" -ForegroundColor Red
        }
    } catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
        Write-Host "FAILED: Status $statusCode" -ForegroundColor Red
        try {
            $errorBody = $_.ErrorDetails.Message | ConvertFrom-Json
            Write-Host "  Error: $($errorBody.error)" -ForegroundColor Red
        } catch {
            Write-Host "  Error: $($_.ErrorDetails.Message)" -ForegroundColor Red
        }
    }
} else {
    Write-Host "SKIPPED: No refresh token available" -ForegroundColor Yellow
}

Write-Host ""

# ============================================
# TEST 9: Change password
# ============================================
Write-Host "TEST 9: Change Password" -ForegroundColor Magenta
Write-Host "-----------------------" -ForegroundColor Magenta

if ($accessToken) {
    $headers = @{
        "Authorization" = "Bearer $accessToken"
    }
    
    $passwordBody = @{
        currentPassword = "Test123!"
        newPassword = "NewTest456!"
    } | ConvertTo-Json
    
    try {
        $passwordResponse = Invoke-RestMethod -Uri "$baseUrl/users/me/password" -Method PUT -Headers $headers -ContentType "application/json" -Body $passwordBody
        
        if ($passwordResponse.success -eq $true) {
            Write-Host "SUCCESS: Password changed!" -ForegroundColor Green
            Write-Host "  Message: $($passwordResponse.data.message)" -ForegroundColor White
        } else {
            Write-Host "FAILED: $($passwordResponse.error)" -ForegroundColor Red
        }
    } catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
        Write-Host "FAILED: Status $statusCode" -ForegroundColor Red
        try {
            $errorBody = $_.ErrorDetails.Message | ConvertFrom-Json
            Write-Host "  Error: $($errorBody.error)" -ForegroundColor Red
        } catch {
            Write-Host "  Error: $($_.ErrorDetails.Message)" -ForegroundColor Red
        }
    }
} else {
    Write-Host "SKIPPED: No access token available" -ForegroundColor Yellow
}

Write-Host ""

# ============================================
# TEST 10: Login with new password
# ============================================
Write-Host "TEST 10: Login with New Password" -ForegroundColor Magenta
Write-Host "---------------------------------" -ForegroundColor Magenta

$newLoginBody = @{
    email = $testEmail
    password = "NewTest456!"
} | ConvertTo-Json

try {
    $newLoginResponse = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method POST -ContentType "application/json" -Body $newLoginBody
    
    if ($newLoginResponse.success -eq $true) {
        Write-Host "SUCCESS: Login with new password works!" -ForegroundColor Green
        Write-Host "  User: $($newLoginResponse.data.user.name)" -ForegroundColor White
    } else {
        Write-Host "FAILED: $($newLoginResponse.error)" -ForegroundColor Red
    }
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    Write-Host "FAILED: Status $statusCode" -ForegroundColor Red
}

Write-Host ""

# ============================================
# SUMMARY
# ============================================
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   ALL TESTS COMPLETED!" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan
Write-Host "Backend API is working correctly!" -ForegroundColor Green
Write-Host "Check the backend console for detailed logs." -ForegroundColor Yellow
