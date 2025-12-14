# =====================================================
# SimStruct Notification System - Backend Test Script
# =====================================================
# Tests all notification REST API endpoints
# Run with: .\test-notifications.ps1
# =====================================================

param(
    [string]$BaseUrl = "http://localhost:8080/api/v1"
)

$ErrorActionPreference = "Stop"

# Test results tracking
$script:passed = 0
$script:failed = 0
$script:testResults = @()

function Write-TestResult {
    param($name, $success, $details)
    $script:testResults += @{
        Name = $name
        Success = $success
        Details = $details
    }
    if ($success) { 
        $script:passed++
        Write-Host "[PASS] $name - $details" -ForegroundColor Green
    } else { 
        $script:failed++
        Write-Host "[FAIL] $name - $details" -ForegroundColor Red
    }
}

# Global variables
$script:token = ""
$script:userId = ""
$script:user2Token = ""
$script:user2Id = ""

function Invoke-Api {
    param(
        [string]$Method,
        [string]$Endpoint,
        [object]$Body = $null,
        [string]$Token = $script:token,
        [switch]$NoAuth
    )
    
    $headers = @{
        "Content-Type" = "application/json"
    }
    
    if (-not $NoAuth -and $Token) {
        $headers["Authorization"] = "Bearer $Token"
    }
    
    $uri = "$BaseUrl$Endpoint"
    
    try {
        if ($Body) {
            $response = Invoke-RestMethod -Uri $uri -Method $Method -Headers $headers -Body ($Body | ConvertTo-Json -Depth 10)
        } else {
            $response = Invoke-RestMethod -Uri $uri -Method $Method -Headers $headers
        }
        return @{ Success = $true; Data = $response }
    }
    catch {
        return @{ Success = $false; Error = $_.Exception.Message }
    }
}

# =====================================================
# Test 1: User Registration
# =====================================================

Write-Host "`n========== TEST 1: User Registration ==========`n" -ForegroundColor Yellow

$testUser1 = @{
    name = "NotifTest User1"
    email = "notif_test1_$(Get-Date -Format 'yyyyMMddHHmmss')@test.com"
    password = "Test123!"
}

Write-Host "Registering first test user: $($testUser1.email)"
$result = Invoke-Api -Method "POST" -Endpoint "/auth/register" -Body $testUser1 -NoAuth

if ($result.Success -and $result.Data.data.accessToken) {
    $script:token = $result.Data.data.accessToken
    $script:userId = $result.Data.data.user.id
    Write-TestResult "User 1 Registration" $true "Token received"
}
else {
    Write-TestResult "User 1 Registration" $false $result.Error
}

# Register second user
$testUser2 = @{
    name = "NotifTest User2"
    email = "notif_test2_$(Get-Date -Format 'yyyyMMddHHmmss')@test.com"
    password = "Test123!"
}

Write-Host "Registering second test user: $($testUser2.email)"
$result = Invoke-Api -Method "POST" -Endpoint "/auth/register" -Body $testUser2 -NoAuth

if ($result.Success -and $result.Data.data.accessToken) {
    $script:user2Token = $result.Data.data.accessToken
    $script:user2Id = $result.Data.data.user.id
    Write-TestResult "User 2 Registration" $true "Token received"
}
else {
    Write-TestResult "User 2 Registration" $false $result.Error
}

# =====================================================
# Test 2: Welcome Notification
# =====================================================

Write-Host "`n========== TEST 2: Welcome Notification ==========`n" -ForegroundColor Yellow

Start-Sleep -Milliseconds 500

$result = Invoke-Api -Method "GET" -Endpoint "/notifications"

if ($result.Success) {
    $notifications = $result.Data.data
    $welcomeNotif = $notifications | Where-Object { $_.type -eq "WELCOME" }
    
    if ($welcomeNotif) {
        Write-Host "Title: $($welcomeNotif.title)"
        Write-Host "Message: $($welcomeNotif.message)"
        Write-TestResult "Welcome Notification" $true "Notification created on registration"
    }
    else {
        Write-TestResult "Welcome Notification" $false "No WELCOME notification found"
    }
}
else {
    Write-TestResult "Welcome Notification" $false $result.Error
}

# =====================================================
# Test 3: Notification Count
# =====================================================

Write-Host "`n========== TEST 3: Notification Count ==========`n" -ForegroundColor Yellow

$result = Invoke-Api -Method "GET" -Endpoint "/notifications/count"

if ($result.Success) {
    $counts = $result.Data.data
    Write-Host "Unread: $($counts.unreadCount), Total: $($counts.totalCount)"
    Write-TestResult "Notification Count" $true "Unread: $($counts.unreadCount)"
}
else {
    Write-TestResult "Notification Count" $false $result.Error
}

# =====================================================
# Test 4: Friend Request Notification
# =====================================================

Write-Host "`n========== TEST 4: Friend Request Notification ==========`n" -ForegroundColor Yellow

Write-Host "User 1 sending friend request to User 2..."
$result = Invoke-Api -Method "POST" -Endpoint "/friends/request/$($script:user2Id)"

if ($result.Success) {
    Start-Sleep -Milliseconds 500
    $result2 = Invoke-Api -Method "GET" -Endpoint "/notifications" -Token $script:user2Token
    
    if ($result2.Success) {
        $friendReqNotif = $result2.Data.data | Where-Object { $_.type -eq "FRIEND_REQUEST" }
        
        if ($friendReqNotif) {
            Write-Host "Title: $($friendReqNotif.title)"
            Write-TestResult "Friend Request Notification" $true "Notification delivered"
        }
        else {
            Write-TestResult "Friend Request Notification" $false "No notification"
        }
    }
}
else {
    Write-TestResult "Friend Request Notification" $false $result.Error
}

# =====================================================
# Test 5: Friend Accept Notification
# =====================================================

Write-Host "`n========== TEST 5: Friend Accept Notification ==========`n" -ForegroundColor Yellow

Write-Host "User 2 accepting friend request..."
$result = Invoke-Api -Method "POST" -Endpoint "/friends/accept/$($script:userId)" -Token $script:user2Token

if ($result.Success) {
    Start-Sleep -Milliseconds 500
    $result2 = Invoke-Api -Method "GET" -Endpoint "/notifications"
    
    if ($result2.Success) {
        $acceptNotif = $result2.Data.data | Where-Object { $_.type -eq "FRIEND_ACCEPTED" }
        
        if ($acceptNotif) {
            Write-Host "Title: $($acceptNotif.title)"
            Write-TestResult "Friend Accept Notification" $true "Notification delivered"
        }
        else {
            Write-TestResult "Friend Accept Notification" $false "No notification"
        }
    }
}
else {
    Write-TestResult "Friend Accept Notification" $false $result.Error
}

# =====================================================
# Test 6: Chat Message Notification
# =====================================================

Write-Host "`n========== TEST 6: Chat Message Notification ==========`n" -ForegroundColor Yellow

$messageBody = @{
    receiverId = $script:user2Id
    content = "Hello! This is a test message."
}

Write-Host "User 1 sending message to User 2..."
$result = Invoke-Api -Method "POST" -Endpoint "/chat/send" -Body $messageBody

if ($result.Success) {
    Start-Sleep -Milliseconds 500
    $result2 = Invoke-Api -Method "GET" -Endpoint "/notifications" -Token $script:user2Token
    
    if ($result2.Success) {
        $msgNotif = $result2.Data.data | Where-Object { $_.type -eq "NEW_MESSAGE" }
        
        if ($msgNotif) {
            Write-Host "Title: $($msgNotif.title)"
            Write-TestResult "Chat Message Notification" $true "Notification delivered"
        }
        else {
            Write-TestResult "Chat Message Notification" $false "No notification"
        }
    }
}
else {
    Write-TestResult "Chat Message Notification" $false $result.Error
}

# =====================================================
# Test 7: Simulation Completion Notification
# =====================================================

Write-Host "`n========== TEST 7: Simulation Notification ==========`n" -ForegroundColor Yellow

$simBody = @{
    name = "Test Notification Simulation"
    description = "Testing notification"
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

Write-Host "Creating simulation..."
$result = Invoke-Api -Method "POST" -Endpoint "/simulations" -Body $simBody

if ($result.Success -and $result.Data.data.status -eq "COMPLETED") {
    $script:testSimulationId = $result.Data.data.id
    
    Start-Sleep -Milliseconds 500
    $result2 = Invoke-Api -Method "GET" -Endpoint "/notifications"
    
    if ($result2.Success) {
        $simNotif = $result2.Data.data | Where-Object { $_.type -eq "SIMULATION_COMPLETE" }
        
        if ($simNotif) {
            Write-Host "Title: $($simNotif.title)"
            Write-TestResult "Simulation Notification" $true "Notification delivered"
        }
        else {
            Write-TestResult "Simulation Notification" $false "No notification"
        }
    }
}
else {
    Write-TestResult "Simulation Notification" $false $result.Error
}

# =====================================================
# Test 8: Share Simulation Notification
# =====================================================

Write-Host "`n========== TEST 8: Share Notification ==========`n" -ForegroundColor Yellow

if ($script:testSimulationId) {
    Write-Host "User 1 sharing simulation with User 2..."
    $result = Invoke-Api -Method "POST" -Endpoint "/shares?simulationId=$($script:testSimulationId)&friendId=$($script:user2Id)&permission=VIEW"
    
    if ($result.Success) {
        Start-Sleep -Milliseconds 500
        $result2 = Invoke-Api -Method "GET" -Endpoint "/notifications" -Token $script:user2Token
        
        if ($result2.Success) {
            $shareNotif = $result2.Data.data | Where-Object { $_.type -eq "SIMULATION_RECEIVED" }
            
            if ($shareNotif) {
                Write-Host "Title: $($shareNotif.title)"
                Write-TestResult "Share Notification" $true "Notification delivered"
            }
            else {
                Write-TestResult "Share Notification" $false "No notification"
            }
        }
    }
    else {
        Write-TestResult "Share Notification" $false $result.Error
    }
}
else {
    Write-TestResult "Share Notification" $false "No simulation to share"
}

# =====================================================
# Test 9: Mark as Read
# =====================================================

Write-Host "`n========== TEST 9: Mark as Read ==========`n" -ForegroundColor Yellow

$result = Invoke-Api -Method "GET" -Endpoint "/notifications"

if ($result.Success -and $result.Data.data.Count -gt 0) {
    $firstNotif = $result.Data.data[0]
    
    Write-Host "Marking notification as read: $($firstNotif.id)"
    $markResult = Invoke-Api -Method "PUT" -Endpoint "/notifications/$($firstNotif.id)/read"
    
    if ($markResult.Success) {
        Write-TestResult "Mark as Read" $true "Notification updated"
    }
    else {
        Write-TestResult "Mark as Read" $false $markResult.Error
    }
}
else {
    Write-TestResult "Mark as Read" $false "No notifications"
}

# =====================================================
# Test 10: Mark All as Read
# =====================================================

Write-Host "`n========== TEST 10: Mark All as Read ==========`n" -ForegroundColor Yellow

$result = Invoke-Api -Method "PUT" -Endpoint "/notifications/read-all"

if ($result.Success) {
    $countResult = Invoke-Api -Method "GET" -Endpoint "/notifications/count"
    
    if ($countResult.Success -and $countResult.Data.data.unreadCount -eq 0) {
        Write-TestResult "Mark All Read" $true "All marked as read"
    }
    else {
        Write-TestResult "Mark All Read" $false "Some still unread"
    }
}
else {
    Write-TestResult "Mark All Read" $false $result.Error
}

# =====================================================
# Test Summary
# =====================================================

Write-Host "`n========== TEST SUMMARY ==========`n" -ForegroundColor Yellow

Write-Host "Total Tests: $($script:passed + $script:failed)" -ForegroundColor White
Write-Host "Passed: $($script:passed)" -ForegroundColor Green
Write-Host "Failed: $($script:failed)" -ForegroundColor Red

if ($script:failed -eq 0) {
    Write-Host "`nAll tests passed! Notification system is working correctly." -ForegroundColor Green
}
else {
    Write-Host "`nSome tests failed. Check backend logs for details." -ForegroundColor Yellow
}

# Save results
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$logFile = "LOGS/notification-test-$timestamp.txt"

$logContent = "Notification Test Results - $(Get-Date)`n"
$logContent += "Passed: $($script:passed), Failed: $($script:failed)`n`n"

foreach ($test in $script:testResults) {
    $status = if ($test.Success) { "PASS" } else { "FAIL" }
    $logContent += "[$status] $($test.Name): $($test.Details)`n"
}

$logContent | Out-File -FilePath $logFile -Encoding UTF8
Write-Host "`nResults saved to: $logFile" -ForegroundColor Cyan
