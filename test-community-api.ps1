# API Test Script for Function 3 (Community & Chat)
# Run this with PowerShell after starting the backend

$baseUrl = "http://localhost:8080/api/v1"
$results = @()
$testUser1 = @{ email = "testuser1_$(Get-Date -Format 'yyyyMMddHHmmss')@test.com"; password = "Test123!"; name = "Test User 1" }
$testUser2 = @{ email = "testuser2_$(Get-Date -Format 'yyyyMMddHHmmss')@test.com"; password = "Test123!"; name = "Test User 2" }
$token1 = $null
$token2 = $null
$user1Id = $null
$user2Id = $null

function Test-Endpoint {
    param($Name, $Method, $Endpoint, $Body, $Token)
    
    $headers = @{ "Content-Type" = "application/json" }
    if ($Token) { $headers["Authorization"] = "Bearer $Token" }
    
    try {
        $params = @{
            Uri = "$baseUrl$Endpoint"
            Method = $Method
            Headers = $headers
            ContentType = "application/json"
        }
        if ($Body) { $params["Body"] = ($Body | ConvertTo-Json -Depth 5) }
        
        $response = Invoke-WebRequest @params -ErrorAction Stop
        $result = @{
            Name = $Name; Method = $Method; Endpoint = $Endpoint
            StatusCode = $response.StatusCode; Status = "PASS"
            Response = ($response.Content | ConvertFrom-Json -ErrorAction SilentlyContinue)
        }
    }
    catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
        $result = @{
            Name = $Name; Method = $Method; Endpoint = $Endpoint
            StatusCode = $statusCode; Status = "FAIL"; Error = $_.Exception.Message
        }
    }
    
    $script:results += $result
    $icon = if ($result.Status -eq "PASS") { "✅" } else { "❌" }
    Write-Host "$icon $Name - $($result.StatusCode)"
    return $result
}

Write-Host "`n========== FUNCTION 3: COMMUNITY & CHAT TESTS ==========" -ForegroundColor Cyan
Write-Host "Testing backend at: $baseUrl" -ForegroundColor Yellow
Write-Host ""

# ========== AUTHENTICATION ==========
Write-Host "`n--- Authentication Setup ---" -ForegroundColor Magenta

# Register User 1
$res = Test-Endpoint -Name "Register User 1" -Method "POST" -Endpoint "/auth/register" -Body $testUser1
if ($res.Response.data.id) { $script:user1Id = $res.Response.data.id }

# Register User 2
$res = Test-Endpoint -Name "Register User 2" -Method "POST" -Endpoint "/auth/register" -Body $testUser2
if ($res.Response.data.id) { $script:user2Id = $res.Response.data.id }

# Login User 1
$res = Test-Endpoint -Name "Login User 1" -Method "POST" -Endpoint "/auth/login" -Body @{ email = $testUser1.email; password = $testUser1.password }
if ($res.Response.data.accessToken) { $script:token1 = $res.Response.data.accessToken }

# Login User 2
$res = Test-Endpoint -Name "Login User 2" -Method "POST" -Endpoint "/auth/login" -Body @{ email = $testUser2.email; password = $testUser2.password }
if ($res.Response.data.accessToken) { $script:token2 = $res.Response.data.accessToken }

# ========== FRIENDSHIP TESTS ==========
Write-Host "`n--- Friendship APIs ---" -ForegroundColor Magenta

# Get friends (empty at first)
Test-Endpoint -Name "Get Friends (Empty)" -Method "GET" -Endpoint "/friends" -Token $token1

# Search for users
Test-Endpoint -Name "Search Users" -Method "GET" -Endpoint "/friends/search?query=Test" -Token $token1

# Send friend request from user1 to user2
if ($user2Id) {
    Test-Endpoint -Name "Send Friend Request" -Method "POST" -Endpoint "/friends/request/$user2Id" -Token $token1
}

# Get sent invitations (user1)
Test-Endpoint -Name "Get Sent Invitations" -Method "GET" -Endpoint "/friends/sent" -Token $token1

# Get pending invitations (user2 - should have one from user1)
Test-Endpoint -Name "Get Pending Invitations" -Method "GET" -Endpoint "/friends/invitations" -Token $token2

# Accept friend request (user2 accepts user1)
if ($user1Id) {
    Test-Endpoint -Name "Accept Friend Request" -Method "POST" -Endpoint "/friends/accept/$user1Id" -Token $token2
}

# Get friends (should have one now)
Test-Endpoint -Name "Get Friends (After Accept)" -Method "GET" -Endpoint "/friends" -Token $token1

# ========== SIMULATION SHARING TESTS ==========
Write-Host "`n--- Simulation Sharing APIs ---" -ForegroundColor Magenta

# Create a simulation first (user1)
$simulationBody = @{
    name = "Test Beam for Sharing"
    description = "Testing share functionality"
    beamLength = 10
    beamWidth = 0.5
    beamHeight = 0.8
    materialType = "STEEL"
    elasticModulus = 200000
    loadType = "POINT"
    loadMagnitude = 50
    supportType = "SIMPLY_SUPPORTED"
}
$simRes = Test-Endpoint -Name "Create Simulation for Sharing" -Method "POST" -Endpoint "/simulations" -Body $simulationBody -Token $token1
$simulationId = if ($simRes.Response.data.id) { $simRes.Response.data.id } else { "test-sim-id" }

# Get my shares (empty)
Test-Endpoint -Name "Get My Shares (Empty)" -Method "GET" -Endpoint "/shares/my-shares" -Token $token1

# Share simulation with friend
if ($user2Id -and $simulationId) {
    Test-Endpoint -Name "Share Simulation" -Method "POST" -Endpoint "/shares?simulationId=$simulationId&friendId=$user2Id&permission=VIEW" -Token $token1
}

# Get my shares (should have one)
Test-Endpoint -Name "Get My Shares (After Share)" -Method "GET" -Endpoint "/shares/my-shares" -Token $token1

# Get shared with me (user2)
Test-Endpoint -Name "Get Shared With Me" -Method "GET" -Endpoint "/shares/shared-with-me" -Token $token2

# Get shares with friend
if ($user2Id) {
    Test-Endpoint -Name "Get Shares With Friend" -Method "GET" -Endpoint "/shares/with-friend/$user2Id" -Token $token1
}

# ========== CHAT TESTS ==========
Write-Host "`n--- Chat APIs ---" -ForegroundColor Magenta

# Get conversations (empty)
Test-Endpoint -Name "Get Conversations (Empty)" -Method "GET" -Endpoint "/chat/conversations" -Token $token1

# Send message from user1 to user2
if ($user2Id) {
    Test-Endpoint -Name "Send Message" -Method "POST" -Endpoint "/chat/send" -Body @{ receiverId = $user2Id; content = "Hello! This is a test message." } -Token $token1
}

# Get conversation with user2
if ($user2Id) {
    Test-Endpoint -Name "Get Conversation" -Method "GET" -Endpoint "/chat/conversation/$user2Id?limit=50" -Token $token1
}

# Get conversations (should have one now)
Test-Endpoint -Name "Get Conversations (After Send)" -Method "GET" -Endpoint "/chat/conversations" -Token $token1

# Get unread count (user2)
Test-Endpoint -Name "Get Unread Count" -Method "GET" -Endpoint "/chat/unread" -Token $token2

# Mark as read (user2)
if ($user1Id) {
    Test-Endpoint -Name "Mark As Read" -Method "POST" -Endpoint "/chat/read/$user1Id" -Token $token2
}

# Send reply from user2 to user1
if ($user1Id) {
    Test-Endpoint -Name "Send Reply" -Method "POST" -Endpoint "/chat/send" -Body @{ receiverId = $user1Id; content = "Hi! Got your message." } -Token $token2
}

# ========== CLEANUP TESTS ==========
Write-Host "`n--- Cleanup Tests ---" -ForegroundColor Magenta

# Remove friend
if ($user2Id) {
    Test-Endpoint -Name "Remove Friend" -Method "DELETE" -Endpoint "/friends/$user2Id" -Token $token1
}

# Get friends (should be empty)
Test-Endpoint -Name "Get Friends (After Remove)" -Method "GET" -Endpoint "/friends" -Token $token1

# ========== SUMMARY ==========
$passed = ($results | Where-Object { $_.Status -eq "PASS" }).Count
$failed = ($results | Where-Object { $_.Status -eq "FAIL" }).Count
$total = $results.Count

Write-Host "`n========== TEST SUMMARY ==========" -ForegroundColor Cyan
Write-Host "Total: $total | Passed: $passed | Failed: $failed" -ForegroundColor $(if ($failed -eq 0) { "Green" } else { "Yellow" })

# Generate report
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$reportPath = "c:\Users\Hamza\Documents\EMSI 5\PFA\LOGS\community-api-test-$timestamp.md"

$report = @"
# Community API Test Results - $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

## Summary
- **Total Tests:** $total
- **Passed:** $passed
- **Failed:** $failed

## Test Results

| Status | Name | Method | Endpoint | Status Code |
|--------|------|--------|----------|-------------|
"@

foreach ($r in $results) {
    $icon = if ($r.Status -eq "PASS") { "✅" } else { "❌" }
    $report += "`n| $icon $($r.Status) | $($r.Name) | $($r.Method) | $($r.Endpoint) | $($r.StatusCode) |"
}

if ($failed -gt 0) {
    $report += "`n`n## Failed Tests Details`n"
    foreach ($r in ($results | Where-Object { $_.Status -eq "FAIL" })) {
        $report += "`n### $($r.Name)"
        $report += "`n- **Endpoint:** $($r.Method) $($r.Endpoint)"
        $report += "`n- **Status Code:** $($r.StatusCode)"
        $report += "`n- **Error:** $($r.Error)`n"
    }
}

$report | Out-File -FilePath $reportPath -Encoding UTF8
Write-Host "`nReport saved to: $reportPath" -ForegroundColor Green
