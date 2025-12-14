# =====================================================
# SimStruct Notification System - Backend Test Script
# =====================================================
# Tests all notification REST API endpoints
# Run with: .\test-backend-notifications.ps1
# =====================================================

param(
    [string]$BaseUrl = "http://localhost:8080/api/v1",
    [switch]$SkipAuth
)

$ErrorActionPreference = "Stop"

# Colors for output
function Write-Success { param($msg) Write-Host "✅ $msg" -ForegroundColor Green }
function Write-Failure { param($msg) Write-Host "❌ $msg" -ForegroundColor Red }
function Write-Info { param($msg) Write-Host "ℹ️  $msg" -ForegroundColor Cyan }
function Write-Header { param($msg) Write-Host "`n========== $msg ==========`n" -ForegroundColor Yellow }

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

# Global variables
$script:token = ""
$script:userId = ""
$script:user2Token = ""
$script:user2Id = ""

# =====================================================
# Helper Functions
# =====================================================

function Invoke-ApiRequest {
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
    
    $params = @{
        Method = $Method
        Uri = "$BaseUrl$Endpoint"
        Headers = $headers
    }
    
    if ($Body) {
        $params["Body"] = ($Body | ConvertTo-Json -Depth 10)
    }
    
    try {
        $response = Invoke-RestMethod @params
        return @{ Success = $true; Data = $response }
    }
    catch {
        $errorMessage = $_.Exception.Message
        try {
            $errorBody = $_.ErrorDetails.Message | ConvertFrom-Json
            $errorMessage = $errorBody.message
        } catch {}
        return @{ Success = $false; Error = $errorMessage; StatusCode = $_.Exception.Response.StatusCode }
    }
}

# =====================================================
# Test 1: User Registration and Login
# =====================================================

Write-Header "TEST 1: User Registration and Authentication"

# Register first test user
$testUser1 = @{
    name = "NotifTest User1"
    email = "notif_test1_$(Get-Date -Format 'yyyyMMddHHmmss')@test.com"
    password = "Test123!"
}

Write-Info "Registering first test user: $($testUser1.email)"
$result = Invoke-ApiRequest -Method "POST" -Endpoint "/auth/register" -Body $testUser1 -NoAuth

if ($result.Success -and $result.Data.data.accessToken) {
    $script:token = $result.Data.data.accessToken
    $script:userId = $result.Data.data.user.id
    Write-Success "User 1 registered successfully (ID: $($script:userId))"
    Add-TestResult "User 1 Registration" $true "Token received"
}
else {
    Write-Failure "User 1 registration failed: $($result.Error)"
    Add-TestResult "User 1 Registration" $false $result.Error
}

# Register second test user (for friend request tests)
$testUser2 = @{
    name = "NotifTest User2"
    email = "notif_test2_$(Get-Date -Format 'yyyyMMddHHmmss')@test.com"
    password = "Test123!"
}

Write-Info "Registering second test user: $($testUser2.email)"
$result = Invoke-ApiRequest -Method "POST" -Endpoint "/auth/register" -Body $testUser2 -NoAuth

if ($result.Success -and $result.Data.data.accessToken) {
    $script:user2Token = $result.Data.data.accessToken
    $script:user2Id = $result.Data.data.user.id
    Write-Success "User 2 registered successfully (ID: $($script:user2Id))"
    Add-TestResult "User 2 Registration" $true "Token received"
}
else {
    Write-Failure "User 2 registration failed: $($result.Error)"
    Add-TestResult "User 2 Registration" $false $result.Error
}

# =====================================================
# Test 2: Welcome Notification Auto-Created
# =====================================================

Write-Header "TEST 2: Welcome Notification (Auto-Created on Registration)"

Start-Sleep -Milliseconds 500  # Wait for notification to be created

$result = Invoke-ApiRequest -Method "GET" -Endpoint "/notifications"

if ($result.Success) {
    $notifications = $result.Data.data
    $welcomeNotif = $notifications | Where-Object { $_.type -eq "WELCOME" }
    
    if ($welcomeNotif) {
        Write-Success "Welcome notification found!"
        Write-Info "Title: $($welcomeNotif.title)"
        Write-Info "Message: $($welcomeNotif.message)"
        Add-TestResult "Welcome Notification" $true "Notification created on registration"
    }
    else {
        Write-Failure "Welcome notification not found"
        Add-TestResult "Welcome Notification" $false "No WELCOME type notification"
    }
}
else {
    Write-Failure "Failed to get notifications: $($result.Error)"
    Add-TestResult "Welcome Notification" $false $result.Error
}

# =====================================================
# Test 3: Get Notification Count
# =====================================================

Write-Header "TEST 3: Get Notification Count"

$result = Invoke-ApiRequest -Method "GET" -Endpoint "/notifications/count"

if ($result.Success) {
    $counts = $result.Data.data
    Write-Success "Notification count retrieved!"
    Write-Info "Unread: $($counts.unreadCount), Total: $($counts.totalCount)"
    Add-TestResult "Notification Count" $true "Unread: $($counts.unreadCount)"
}
else {
    Write-Failure "Failed to get count: $($result.Error)"
    Add-TestResult "Notification Count" $false $result.Error
}

# =====================================================
# Test 4: Get Unread Notifications
# =====================================================

Write-Header "TEST 4: Get Unread Notifications"

$result = Invoke-ApiRequest -Method "GET" -Endpoint "/notifications/unread"

if ($result.Success) {
    $unread = $result.Data.data
    Write-Success "Unread notifications retrieved: $($unread.Count) notifications"
    Add-TestResult "Unread Notifications" $true "Count: $($unread.Count)"
}
else {
    Write-Failure "Failed to get unread: $($result.Error)"
    Add-TestResult "Unread Notifications" $false $result.Error
}

# =====================================================
# Test 5: Friend Request Notification
# =====================================================

Write-Header "TEST 5: Friend Request Notification"

Write-Info "User 1 sending friend request to User 2..."
$result = Invoke-ApiRequest -Method "POST" -Endpoint "/friends/request/$($script:user2Id)"

if ($result.Success) {
    Write-Success "Friend request sent!"
    
    # Check User 2's notifications
    Start-Sleep -Milliseconds 500
    $result2 = Invoke-ApiRequest -Method "GET" -Endpoint "/notifications" -Token $script:user2Token
    
    if ($result2.Success) {
        $friendReqNotif = $result2.Data.data | Where-Object { $_.type -eq "FRIEND_REQUEST" }
        
        if ($friendReqNotif) {
            Write-Success "Friend request notification received by User 2!"
            Write-Info "Title: $($friendReqNotif.title)"
            Write-Info "Message: $($friendReqNotif.message)"
            Add-TestResult "Friend Request Notification" $true "Notification delivered"
        }
        else {
            Write-Failure "Friend request notification not found for User 2"
            Add-TestResult "Friend Request Notification" $false "No notification"
        }
    }
}
else {
    Write-Failure "Friend request failed: $($result.Error)"
    Add-TestResult "Friend Request Notification" $false $result.Error
}

# =====================================================
# Test 6: Friend Accept Notification
# =====================================================

Write-Header "TEST 6: Friend Accept Notification"

Write-Info "User 2 accepting friend request from User 1..."
$result = Invoke-ApiRequest -Method "POST" -Endpoint "/friends/accept/$($script:userId)" -Token $script:user2Token

if ($result.Success) {
    Write-Success "Friend request accepted!"
    
    # Check User 1's notifications
    Start-Sleep -Milliseconds 500
    $result2 = Invoke-ApiRequest -Method "GET" -Endpoint "/notifications"
    
    if ($result2.Success) {
        $acceptNotif = $result2.Data.data | Where-Object { $_.type -eq "FRIEND_ACCEPTED" }
        
        if ($acceptNotif) {
            Write-Success "Friend accepted notification received by User 1!"
            Write-Info "Title: $($acceptNotif.title)"
            Write-Info "Message: $($acceptNotif.message)"
            Add-TestResult "Friend Accept Notification" $true "Notification delivered"
        }
        else {
            Write-Failure "Friend accepted notification not found for User 1"
            Add-TestResult "Friend Accept Notification" $false "No notification"
        }
    }
}
else {
    Write-Failure "Friend accept failed: $($result.Error)"
    Add-TestResult "Friend Accept Notification" $false $result.Error
}

# =====================================================
# Test 7: Chat Message Notification
# =====================================================

Write-Header "TEST 7: Chat Message Notification"

$messageBody = @{
    recipientId = $script:user2Id
    content = "Hello! This is a test message for notification system."
}

Write-Info "User 1 sending message to User 2..."
$result = Invoke-ApiRequest -Method "POST" -Endpoint "/chat/messages" -Body $messageBody

if ($result.Success) {
    Write-Success "Message sent!"
    
    # Check User 2's notifications
    Start-Sleep -Milliseconds 500
    $result2 = Invoke-ApiRequest -Method "GET" -Endpoint "/notifications" -Token $script:user2Token
    
    if ($result2.Success) {
        $msgNotif = $result2.Data.data | Where-Object { $_.type -eq "NEW_MESSAGE" }
        
        if ($msgNotif) {
            Write-Success "New message notification received by User 2!"
            Write-Info "Title: $($msgNotif.title)"
            Write-Info "Message: $($msgNotif.message)"
            Add-TestResult "Chat Message Notification" $true "Notification delivered"
        }
        else {
            Write-Failure "Message notification not found for User 2"
            Add-TestResult "Chat Message Notification" $false "No notification"
        }
    }
}
else {
    Write-Failure "Message send failed: $($result.Error)"
    Add-TestResult "Chat Message Notification" $false $result.Error
}

# =====================================================
# Test 8: Create Simulation (Completion Notification)
# =====================================================

Write-Header "TEST 8: Simulation Completion Notification"

$simulationBody = @{
    name = "Test Notification Simulation"
    description = "Testing notification on simulation completion"
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

Write-Info "Creating simulation..."
$result = Invoke-ApiRequest -Method "POST" -Endpoint "/simulations" -Body $simulationBody

if ($result.Success -and $result.Data.data.status -eq "COMPLETED") {
    Write-Success "Simulation created and completed!"
    $simId = $result.Data.data.id
    
    # Check for completion notification
    Start-Sleep -Milliseconds 500
    $result2 = Invoke-ApiRequest -Method "GET" -Endpoint "/notifications"
    
    if ($result2.Success) {
        $simNotif = $result2.Data.data | Where-Object { $_.type -eq "SIMULATION_COMPLETE" }
        
        if ($simNotif) {
            Write-Success "Simulation completion notification received!"
            Write-Info "Title: $($simNotif.title)"
            Write-Info "Message: $($simNotif.message)"
            Add-TestResult "Simulation Notification" $true "Notification delivered"
        }
        else {
            Write-Failure "Simulation completion notification not found"
            Add-TestResult "Simulation Notification" $false "No notification"
        }
    }
    
    # Store simulation ID for share test
    $script:testSimulationId = $simId
}
else {
    Write-Failure "Simulation creation failed: $($result.Error)"
    Add-TestResult "Simulation Notification" $false $result.Error
}

# =====================================================
# Test 9: Share Simulation Notification
# =====================================================

Write-Header "TEST 9: Share Simulation Notification"

if ($script:testSimulationId) {
    $shareBody = @{
        simulationId = $script:testSimulationId
        sharedWithId = $script:user2Id
        permission = "VIEW"
    }
    
    Write-Info "User 1 sharing simulation with User 2..."
    $result = Invoke-ApiRequest -Method "POST" -Endpoint "/shares" -Body $shareBody
    
    if ($result.Success) {
        Write-Success "Simulation shared!"
        
        # Check User 2's notifications
        Start-Sleep -Milliseconds 500
        $result2 = Invoke-ApiRequest -Method "GET" -Endpoint "/notifications" -Token $script:user2Token
        
        if ($result2.Success) {
            $shareNotif = $result2.Data.data | Where-Object { $_.type -eq "SIMULATION_RECEIVED" }
            
            if ($shareNotif) {
                Write-Success "Share notification received by User 2!"
                Write-Info "Title: $($shareNotif.title)"
                Write-Info "Message: $($shareNotif.message)"
                Add-TestResult "Share Notification" $true "Notification delivered"
            }
            else {
                Write-Failure "Share notification not found for User 2"
                Add-TestResult "Share Notification" $false "No notification"
            }
        }
    }
    else {
        Write-Failure "Share failed: $($result.Error)"
        Add-TestResult "Share Notification" $false $result.Error
    }
}
else {
    Write-Info "Skipping share test (no simulation created)"
    Add-TestResult "Share Notification" $false "No simulation to share"
}

# =====================================================
# Test 10: Mark Notification as Read
# =====================================================

Write-Header "TEST 10: Mark Notification as Read"

$result = Invoke-ApiRequest -Method "GET" -Endpoint "/notifications"

if ($result.Success -and $result.Data.data.Count -gt 0) {
    $firstNotif = $result.Data.data[0]
    
    Write-Info "Marking notification as read: $($firstNotif.id)"
    $markResult = Invoke-ApiRequest -Method "PUT" -Endpoint "/notifications/$($firstNotif.id)/read"
    
    if ($markResult.Success) {
        Write-Success "Notification marked as read!"
        
        # Verify
        $verifyResult = Invoke-ApiRequest -Method "GET" -Endpoint "/notifications"
        $updatedNotif = $verifyResult.Data.data | Where-Object { $_.id -eq $firstNotif.id }
        
        if ($updatedNotif.isRead -eq $true) {
            Write-Success "Verified: notification isRead = true"
            Add-TestResult "Mark as Read" $true "Notification updated"
        }
        else {
            Write-Failure "Notification not marked as read"
            Add-TestResult "Mark as Read" $false "isRead still false"
        }
    }
    else {
        Write-Failure "Mark as read failed: $($markResult.Error)"
        Add-TestResult "Mark as Read" $false $markResult.Error
    }
}
else {
    Write-Failure "No notifications to mark as read"
    Add-TestResult "Mark as Read" $false "No notifications"
}

# =====================================================
# Test 11: Mark All as Read
# =====================================================

Write-Header "TEST 11: Mark All Notifications as Read"

$result = Invoke-ApiRequest -Method "PUT" -Endpoint "/notifications/read-all"

if ($result.Success) {
    Write-Success "All notifications marked as read!"
    
    # Verify count
    $countResult = Invoke-ApiRequest -Method "GET" -Endpoint "/notifications/count"
    
    if ($countResult.Success -and $countResult.Data.data.unreadCount -eq 0) {
        Write-Success "Verified: unread count is 0"
        Add-TestResult "Mark All Read" $true "All marked as read"
    }
    else {
        Write-Failure "Some notifications still unread"
        Add-TestResult "Mark All Read" $false "Unread: $($countResult.Data.data.unreadCount)"
    }
}
else {
    Write-Failure "Mark all as read failed: $($result.Error)"
    Add-TestResult "Mark All Read" $false $result.Error
}

# =====================================================
# Test 12: Delete Single Notification
# =====================================================

Write-Header "TEST 12: Delete Single Notification"

$result = Invoke-ApiRequest -Method "GET" -Endpoint "/notifications"

if ($result.Success -and $result.Data.data.Count -gt 0) {
    $notifToDelete = $result.Data.data[0]
    $beforeCount = $result.Data.data.Count
    
    Write-Info "Deleting notification: $($notifToDelete.id)"
    $deleteResult = Invoke-ApiRequest -Method "DELETE" -Endpoint "/notifications/$($notifToDelete.id)"
    
    if ($deleteResult.Success) {
        Write-Success "Notification deleted!"
        
        # Verify
        $afterResult = Invoke-ApiRequest -Method "GET" -Endpoint "/notifications"
        $afterCount = $afterResult.Data.data.Count
        
        if ($afterCount -eq ($beforeCount - 1)) {
            Write-Success "Verified: notification count reduced from $beforeCount to $afterCount"
            Add-TestResult "Delete Notification" $true "Notification removed"
        }
        else {
            Write-Failure "Count mismatch after delete"
            Add-TestResult "Delete Notification" $false "Count mismatch"
        }
    }
    else {
        Write-Failure "Delete failed: $($deleteResult.Error)"
        Add-TestResult "Delete Notification" $false $deleteResult.Error
    }
}
else {
    Write-Failure "No notifications to delete"
    Add-TestResult "Delete Notification" $false "No notifications"
}

# =====================================================
# Test 13: Paginated Notifications
# =====================================================

Write-Header "TEST 13: Paginated Notifications"

$result = Invoke-ApiRequest -Method "GET" -Endpoint "/notifications/page?page=0`&size=5"

if ($result.Success) {
    $pageData = $result.Data.data
    Write-Success "Paginated notifications retrieved!"
    Write-Info "Content count: $($pageData.content.Count)"
    Write-Info "Total elements: $($pageData.totalElements)"
    Write-Info "Total pages: $($pageData.totalPages)"
    Write-Info "Page size: $($pageData.size)"
    Add-TestResult "Paginated Notifications" $true "Page 0 retrieved"
}
else {
    Write-Failure "Failed to get paginated notifications: $($result.Error)"
    Add-TestResult "Paginated Notifications" $false $result.Error
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
    Write-Host "🎉 All tests passed! Notification system is working correctly." -ForegroundColor Green
}
else {
    Write-Host "⚠️  Some tests failed. Please check the backend logs for details." -ForegroundColor Yellow
}

# Save results to file
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$logFile = "LOGS/notification-test-results-$timestamp.md"

$logContent = "# Notification System Test Results`n"
$logContent += "Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`n"
$logContent += "Backend URL: $BaseUrl`n`n"
$logContent += "## Summary`n"
$logContent += "Total Tests: $($script:passed + $script:failed)`n"
$logContent += "Passed: $($script:passed)`n"
$logContent += "Failed: $($script:failed)`n`n"

foreach ($test in $script:testResults) {
    $status = if ($test.Success) { "PASS" } else { "FAIL" }
    $logContent += "[$status] $($test.Timestamp) - $($test.Name): $($test.Details)`n"
}

$logContent | Out-File -FilePath $logFile -Encoding UTF8
Write-Info "Test results saved to: $logFile"
