# ====================================================
# SIMSTRUCT - FRONTEND COMMUNITY & CHAT TEST SCRIPT
# Tests all Function 3 features via API simulation
# ====================================================

$baseUrl = "http://localhost:8080/api/v1"
$frontendUrl = "http://localhost:4200"
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$logFile = "LOGS/frontend-test-$timestamp.log"

# Ensure LOGS directory exists
if (!(Test-Path "LOGS")) { New-Item -ItemType Directory -Path "LOGS" | Out-Null }

function Write-Log {
    param($Message, $Color = "White")
    $logEntry = "$(Get-Date -Format 'HH:mm:ss') - $Message"
    Write-Host $logEntry -ForegroundColor $Color
    Add-Content -Path $logFile -Value $logEntry
}

function Test-Endpoint {
    param(
        [string]$Name,
        [string]$Url,
        [int]$ExpectedStatus = 200
    )
    
    try {
        $response = Invoke-WebRequest -Uri $Url -Method GET -UseBasicParsing -TimeoutSec 10
        if ($response.StatusCode -eq $ExpectedStatus) {
            Write-Log "✅ $Name - Status: $($response.StatusCode)" "Green"
            return $true
        } else {
            Write-Log "❌ $Name - Expected: $ExpectedStatus, Got: $($response.StatusCode)" "Red"
            return $false
        }
    }
    catch {
        Write-Log "❌ $Name - Error: $($_.Exception.Message)" "Red"
        return $false
    }
}

function Test-ApiWithAuth {
    param(
        [string]$Name,
        [string]$Method,
        [string]$Endpoint,
        [string]$Token,
        [string]$Body = $null,
        [int]$ExpectedStatus = 200
    )
    
    try {
        $headers = @{
            "Authorization" = "Bearer $Token"
            "Content-Type" = "application/json"
        }
        
        $params = @{
            Uri = "$baseUrl$Endpoint"
            Method = $Method
            Headers = $headers
            UseBasicParsing = $true
        }
        
        if ($Body) { $params.Body = $Body }
        
        $response = Invoke-WebRequest @params
        $content = $response.Content | ConvertFrom-Json
        
        if ($response.StatusCode -eq $ExpectedStatus -and $content.success) {
            Write-Log "✅ $Name - Status: $($response.StatusCode)" "Green"
            return @{ Success = $true; Data = $content.data }
        } else {
            Write-Log "❌ $Name - Failed" "Red"
            return @{ Success = $false; Data = $null }
        }
    }
    catch {
        $statusCode = 0
        if ($_.Exception.Response) {
            $statusCode = [int]$_.Exception.Response.StatusCode
        }
        Write-Log "❌ $Name - Status: $statusCode - $($_.Exception.Message)" "Red"
        return @{ Success = $false; Data = $null }
    }
}

# ====================================================
# START TESTS
# ====================================================

Write-Log "=" * 60 "Cyan"
Write-Log "SIMSTRUCT FRONTEND - COMMUNITY & CHAT TESTS" "Cyan"
Write-Log "Started: $(Get-Date)" "Cyan"
Write-Log "=" * 60 "Cyan"

$passed = 0
$failed = 0

# ====================================================
# 1. FRONTEND AVAILABILITY
# ====================================================
Write-Log "`n--- FRONTEND AVAILABILITY ---" "Yellow"

if (Test-Endpoint "Frontend Home Page" $frontendUrl) { $passed++ } else { $failed++ }
if (Test-Endpoint "Frontend Assets (favicon)" "$frontendUrl/favicon.ico") { $passed++ } else { $failed++ }

# ====================================================
# 2. BACKEND AVAILABILITY
# ====================================================
Write-Log "`n--- BACKEND AVAILABILITY ---" "Yellow"

if (Test-Endpoint "Backend Health (Auth endpoint)" "$baseUrl/auth/register" -ExpectedStatus 405) { $passed++ } else { $failed++ }

# ====================================================
# 3. CREATE TEST USERS
# ====================================================
Write-Log "`n--- CREATE TEST USERS ---" "Yellow"

# Register User A
$userA = @{
    name = "Frontend User A"
    email = "frontend_a_$timestamp@test.com"
    password = "password123"
} | ConvertTo-Json

try {
    $regA = Invoke-WebRequest -Uri "$baseUrl/auth/register" -Method POST -Body $userA -ContentType "application/json" -UseBasicParsing
    $dataA = ($regA.Content | ConvertFrom-Json).data
    $tokenA = $dataA.accessToken
    $userAId = $dataA.user.id
    Write-Log "✅ Register User A - ID: $userAId" "Green"
    $passed++
} catch {
    Write-Log "❌ Register User A - $($_.Exception.Message)" "Red"
    $failed++
}

# Register User B
$userB = @{
    name = "Frontend User B"
    email = "frontend_b_$timestamp@test.com"
    password = "password123"
} | ConvertTo-Json

try {
    $regB = Invoke-WebRequest -Uri "$baseUrl/auth/register" -Method POST -Body $userB -ContentType "application/json" -UseBasicParsing
    $dataB = ($regB.Content | ConvertFrom-Json).data
    $tokenB = $dataB.accessToken
    $userBId = $dataB.user.id
    Write-Log "✅ Register User B - ID: $userBId" "Green"
    $passed++
} catch {
    Write-Log "❌ Register User B - $($_.Exception.Message)" "Red"
    $failed++
}

# ====================================================
# 4. COMMUNITY FEATURE TESTS
# ====================================================
Write-Log "`n--- COMMUNITY FEATURES (as User A) ---" "Yellow"

# Test: Search for User B
$searchResult = Test-ApiWithAuth "Search for User B" "GET" "/friends/search?query=Frontend" $tokenA
if ($searchResult.Success) { $passed++ } else { $failed++ }

# Test: Search returns correct user (User B should appear)
if ($searchResult.Data -and ($searchResult.Data | Where-Object { $_.id -eq $userBId })) {
    Write-Log "✅ Search returns User B correctly" "Green"
    $passed++
} else {
    Write-Log "❌ Search did NOT return User B" "Red"
    $failed++
}

# Test: Search does NOT return self (User A)
if ($searchResult.Data -and -not ($searchResult.Data | Where-Object { $_.id -eq $userAId })) {
    Write-Log "✅ Search correctly excludes self (User A)" "Green"
    $passed++
} else {
    Write-Log "❌ Search incorrectly returns self (User A)" "Red"
    $failed++
}

# Test: Get Friends (empty)
$friendsEmpty = Test-ApiWithAuth "Get Friends (Empty)" "GET" "/friends" $tokenA
if ($friendsEmpty.Success -and $friendsEmpty.Data.Count -eq 0) { $passed++ } else { $failed++ }

# Test: Send Friend Request
$sendReq = Test-ApiWithAuth "Send Friend Request to User B" "POST" "/friends/request/$userBId" $tokenA
if ($sendReq.Success) { $passed++ } else { $failed++ }

# Test: Check Sent Invitations
$sentInv = Test-ApiWithAuth "Get Sent Invitations" "GET" "/friends/sent" $tokenA
if ($sentInv.Success -and $sentInv.Data.Count -eq 1) { $passed++ } else { $failed++ }

Write-Log "`n--- COMMUNITY FEATURES (as User B) ---" "Yellow"

# Test: Get Pending Invitations
$pendingInv = Test-ApiWithAuth "Get Pending Invitations" "GET" "/friends/invitations" $tokenB
if ($pendingInv.Success -and $pendingInv.Data.Count -eq 1) { $passed++ } else { $failed++ }

# Test: Accept Friend Request
$acceptReq = Test-ApiWithAuth "Accept Friend Request" "POST" "/friends/accept/$userAId" $tokenB
if ($acceptReq.Success) { $passed++ } else { $failed++ }

# Test: Both users now have 1 friend
$friendsA = Test-ApiWithAuth "User A has 1 friend" "GET" "/friends" $tokenA
if ($friendsA.Success -and $friendsA.Data.Count -eq 1) { $passed++ } else { $failed++ }

$friendsB = Test-ApiWithAuth "User B has 1 friend" "GET" "/friends" $tokenB
if ($friendsB.Success -and $friendsB.Data.Count -eq 1) { $passed++ } else { $failed++ }

# Test: Search excludes friends
$searchAfter = Test-ApiWithAuth "Search excludes friends" "GET" "/friends/search?query=Frontend" $tokenA
if ($searchAfter.Success -and -not ($searchAfter.Data | Where-Object { $_.id -eq $userBId })) {
    Write-Log "✅ Search correctly excludes friend (User B)" "Green"
    $passed++
} else {
    Write-Log "❌ Search still shows friend (User B)" "Red"
    $failed++
}

# ====================================================
# 5. SIMULATION SHARING TESTS
# ====================================================
Write-Log "`n--- SIMULATION SHARING ---" "Yellow"

# Create simulation
$simData = @{
    name = "Test Simulation for Sharing"
    supportType = "SIMPLY_SUPPORTED"
    materialType = "STEEL"
    loadType = "POINT_LOAD"
    loadMagnitude = 5000
    beamLength = 6.0
    beamWidth = 0.3
    beamHeight = 0.5
    isPublic = $false
} | ConvertTo-Json

$simResult = Test-ApiWithAuth "Create Simulation" "POST" "/simulations" $tokenA $simData
if ($simResult.Success) { $passed++ } else { $failed++ }
$simId = $simResult.Data.id

# Share simulation
if ($simId) {
    $shareResult = Test-ApiWithAuth "Share Simulation with Friend" "POST" "/shares?simulationId=$simId&friendId=$userBId&permission=VIEW" $tokenA
    if ($shareResult.Success) { $passed++ } else { $failed++ }
    
    # Verify shares
    $myShares = Test-ApiWithAuth "Get My Shares" "GET" "/shares/my-shares" $tokenA
    if ($myShares.Success -and $myShares.Data.Count -eq 1) { $passed++ } else { $failed++ }
    
    $sharedWithMe = Test-ApiWithAuth "Get Shared With Me (User B)" "GET" "/shares/shared-with-me" $tokenB
    if ($sharedWithMe.Success -and $sharedWithMe.Data.Count -eq 1) { $passed++ } else { $failed++ }
}

# ====================================================
# 6. CHAT TESTS
# ====================================================
Write-Log "`n--- CHAT FEATURES ---" "Yellow"

# Get conversations (empty)
$convEmpty = Test-ApiWithAuth "Get Conversations (Empty)" "GET" "/chat/conversations" $tokenA
if ($convEmpty.Success) { $passed++ } else { $failed++ }

# Send message
$msgData = @{
    receiverId = $userBId
    content = "Hello from User A! Testing chat feature."
} | ConvertTo-Json

$sendMsg = Test-ApiWithAuth "Send Chat Message" "POST" "/chat/send" $tokenA $msgData
if ($sendMsg.Success) { $passed++ } else { $failed++ }

# Check unread for User B
$unread = Test-ApiWithAuth "Get Unread Count (User B)" "GET" "/chat/unread" $tokenB
if ($unread.Success -and $unread.Data -ge 1) { $passed++ } else { $failed++ }

# Get conversation
$convMsgs = Test-ApiWithAuth "Get Conversation Messages" "GET" "/chat/conversation/$userBId" $tokenA
if ($convMsgs.Success -and $convMsgs.Data.Count -ge 1) { $passed++ } else { $failed++ }

# Mark as read
$markRead = Test-ApiWithAuth "Mark Messages as Read" "POST" "/chat/read/$userAId" $tokenB
if ($markRead.Success) { $passed++ } else { $failed++ }

# Verify unread is 0
$unreadAfter = Test-ApiWithAuth "Verify Unread is 0" "GET" "/chat/unread" $tokenB
if ($unreadAfter.Success -and $unreadAfter.Data -eq 0) { $passed++ } else { $failed++ }

# ====================================================
# 7. REMOVE FRIEND
# ====================================================
Write-Log "`n--- CLEANUP ---" "Yellow"

if ($friendsA.Data -and $friendsA.Data.Count -gt 0) {
    $friendshipId = $friendsA.Data[0].friendshipId
    $removeResult = Test-ApiWithAuth "Remove Friend" "DELETE" "/friends/$friendshipId" $tokenA
    if ($removeResult.Success) { $passed++ } else { $failed++ }
    
    # Verify no friends
    $friendsAfterRemove = Test-ApiWithAuth "Verify No Friends" "GET" "/friends" $tokenA
    if ($friendsAfterRemove.Success -and $friendsAfterRemove.Data.Count -eq 0) { $passed++ } else { $failed++ }
}

# ====================================================
# SUMMARY
# ====================================================
$total = $passed + $failed

Write-Log "`n" + "=" * 60 "Cyan"
Write-Log "TEST SUMMARY" "Cyan"
Write-Log "=" * 60 "Cyan"
Write-Log "Total Tests: $total" "White"
Write-Log "Passed: $passed" "Green"
Write-Log "Failed: $failed" "Red"
Write-Log "Success Rate: $([math]::Round(($passed / $total) * 100, 1))%" "Cyan"
Write-Log "`nLog saved to: $logFile" "Gray"

# Exit code
if ($failed -eq 0) {
    Write-Log "`n✅ ALL FRONTEND TESTS PASSED!" "Green"
    exit 0
} else {
    Write-Log "`n❌ SOME TESTS FAILED" "Red"
    exit 1
}
