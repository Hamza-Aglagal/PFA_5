# ====================================================
# SIMSTRUCT - BACKEND COMMUNITY & CHAT TEST SCRIPT
# Tests all Function 3 APIs with detailed verification
# ====================================================

$baseUrl = "http://localhost:8080/api/v1"
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$logFile = "LOGS/backend-test-$timestamp.log"

# Ensure LOGS directory exists
if (!(Test-Path "LOGS")) { New-Item -ItemType Directory -Path "LOGS" | Out-Null }

function Write-Log {
    param($Message, $Color = "White")
    $logEntry = "$(Get-Date -Format 'HH:mm:ss') - $Message"
    Write-Host $logEntry -ForegroundColor $Color
    Add-Content -Path $logFile -Value $logEntry
}

function Test-Api {
    param(
        [string]$Name,
        [string]$Method,
        [string]$Endpoint,
        [hashtable]$Headers = @{},
        [string]$Body = $null,
        [int]$ExpectedStatus = 200,
        [scriptblock]$Validation = $null
    )
    
    try {
        $uri = "$baseUrl$Endpoint"
        $params = @{
            Uri = $uri
            Method = $Method
            Headers = $Headers
            ContentType = "application/json"
            UseBasicParsing = $true
        }
        if ($Body) { $params.Body = $Body }
        
        $response = Invoke-WebRequest @params
        $content = $response.Content | ConvertFrom-Json
        
        $passed = $response.StatusCode -eq $ExpectedStatus
        
        # Run validation if provided
        if ($passed -and $Validation) {
            $passed = & $Validation $content
        }
        
        if ($passed) {
            Write-Log "✅ PASS: $Name (Status: $($response.StatusCode))" "Green"
            return @{ Success = $true; Data = $content; StatusCode = $response.StatusCode }
        } else {
            Write-Log "❌ FAIL: $Name - Validation failed" "Red"
            return @{ Success = $false; Data = $content; StatusCode = $response.StatusCode }
        }
    }
    catch {
        $statusCode = 0
        if ($_.Exception.Response) {
            $statusCode = [int]$_.Exception.Response.StatusCode
        }
        Write-Log "❌ FAIL: $Name (Status: $statusCode) - $($_.Exception.Message)" "Red"
        return @{ Success = $false; Error = $_.Exception.Message; StatusCode = $statusCode }
    }
}

# ====================================================
# START TESTS
# ====================================================

Write-Log "=" * 60 "Cyan"
Write-Log "SIMSTRUCT BACKEND - COMMUNITY & CHAT TESTS" "Cyan"
Write-Log "Started: $(Get-Date)" "Cyan"
Write-Log "=" * 60 "Cyan"

$results = @{ Total = 0; Passed = 0; Failed = 0 }

# ====================================================
# 1. AUTHENTICATION SETUP
# ====================================================
Write-Log "`n--- AUTHENTICATION SETUP ---" "Yellow"

# Register User 1
$user1Data = @{
    name = "Hamza Test"
    email = "hamza_test_$timestamp@gmail.com"
    password = "password123"
} | ConvertTo-Json

$reg1 = Test-Api -Name "Register User 1 (Hamza)" -Method POST -Endpoint "/auth/register" -Body $user1Data -ExpectedStatus 201
$results.Total++; if ($reg1.Success) { $results.Passed++ } else { $results.Failed++ }

# Register User 2
$user2Data = @{
    name = "Ag Friend"
    email = "ag_test_$timestamp@gmail.com"
    password = "password123"
} | ConvertTo-Json

$reg2 = Test-Api -Name "Register User 2 (Ag)" -Method POST -Endpoint "/auth/register" -Body $user2Data -ExpectedStatus 201
$results.Total++; if ($reg2.Success) { $results.Passed++ } else { $results.Failed++ }

# Extract tokens and user IDs
$token1 = $reg1.Data.data.accessToken
$token2 = $reg2.Data.data.accessToken
$user1Id = $reg1.Data.data.user.id
$user2Id = $reg2.Data.data.user.id
$user1Email = $reg1.Data.data.user.email
$user2Email = $reg2.Data.data.user.email

Write-Log "User 1 ID: $user1Id, Email: $user1Email" "Gray"
Write-Log "User 2 ID: $user2Id, Email: $user2Email" "Gray"

$headers1 = @{ Authorization = "Bearer $token1" }
$headers2 = @{ Authorization = "Bearer $token2" }

# ====================================================
# 2. USER SEARCH TESTS
# ====================================================
Write-Log "`n--- USER SEARCH TESTS ---" "Yellow"

# Search for User 2 from User 1
$search1 = Test-Api -Name "Search for 'Ag' (should find User 2)" `
    -Method GET -Endpoint "/friends/search?query=Ag" `
    -Headers $headers1 `
    -Validation {
        param($content)
        $found = $content.data | Where-Object { $_.email -like "*ag_test*" }
        return $found -ne $null
    }
$results.Total++; if ($search1.Success) { $results.Passed++ } else { $results.Failed++ }

# Search should NOT return current user
$search2 = Test-Api -Name "Search for 'Hamza' (should NOT return self)" `
    -Method GET -Endpoint "/friends/search?query=Hamza" `
    -Headers $headers1 `
    -Validation {
        param($content)
        $self = $content.data | Where-Object { $_.email -like "*hamza_test*" }
        return $self -eq $null -or $content.data.Count -eq 0
    }
$results.Total++; if ($search2.Success) { $results.Passed++ } else { $results.Failed++ }

# Search by email
$search3 = Test-Api -Name "Search by email 'ag_test'" `
    -Method GET -Endpoint "/friends/search?query=ag_test" `
    -Headers $headers1 `
    -Validation {
        param($content)
        return $content.success -eq $true
    }
$results.Total++; if ($search3.Success) { $results.Passed++ } else { $results.Failed++ }

# ====================================================
# 3. FRIENDSHIP FLOW TESTS
# ====================================================
Write-Log "`n--- FRIENDSHIP FLOW TESTS ---" "Yellow"

# Get friends (should be empty)
$friends1 = Test-Api -Name "Get Friends (Empty)" `
    -Method GET -Endpoint "/friends" `
    -Headers $headers1 `
    -Validation { param($c) return $c.data.Count -eq 0 }
$results.Total++; if ($friends1.Success) { $results.Passed++ } else { $results.Failed++ }

# Send friend request from User 1 to User 2
$sendReq = Test-Api -Name "Send Friend Request (User1 -> User2)" `
    -Method POST -Endpoint "/friends/request/$user2Id" `
    -Headers $headers1 `
    -Validation {
        param($content)
        return $content.data.status -eq "PENDING" -and $content.data.recipientId -eq $user2Id
    }
$results.Total++; if ($sendReq.Success) { $results.Passed++ } else { $results.Failed++ }

# Check sent invitations
$sent = Test-Api -Name "Get Sent Invitations (User1)" `
    -Method GET -Endpoint "/friends/sent" `
    -Headers $headers1 `
    -Validation { param($c) return $c.data.Count -eq 1 }
$results.Total++; if ($sent.Success) { $results.Passed++ } else { $results.Failed++ }

# Check pending invitations for User 2
$pending = Test-Api -Name "Get Pending Invitations (User2)" `
    -Method GET -Endpoint "/friends/invitations" `
    -Headers $headers2 `
    -Validation { param($c) return $c.data.Count -eq 1 }
$results.Total++; if ($pending.Success) { $results.Passed++ } else { $results.Failed++ }

# Accept friend request
$accept = Test-Api -Name "Accept Friend Request (User2)" `
    -Method POST -Endpoint "/friends/accept/$user1Id" `
    -Headers $headers2 `
    -Validation { param($c) return $c.data.status -eq "ACCEPTED" }
$results.Total++; if ($accept.Success) { $results.Passed++ } else { $results.Failed++ }

# Verify friendship from both sides
$friends2 = Test-Api -Name "Verify Friends (User1 side)" `
    -Method GET -Endpoint "/friends" `
    -Headers $headers1 `
    -Validation { param($c) return $c.data.Count -eq 1 }
$results.Total++; if ($friends2.Success) { $results.Passed++ } else { $results.Failed++ }

$friends3 = Test-Api -Name "Verify Friends (User2 side)" `
    -Method GET -Endpoint "/friends" `
    -Headers $headers2 `
    -Validation { param($c) return $c.data.Count -eq 1 }
$results.Total++; if ($friends3.Success) { $results.Passed++ } else { $results.Failed++ }

# Search should exclude existing friends
$search4 = Test-Api -Name "Search excludes existing friends" `
    -Method GET -Endpoint "/friends/search?query=Ag" `
    -Headers $headers1 `
    -Validation {
        param($content)
        $friend = $content.data | Where-Object { $_.id -eq $user2Id }
        return $friend -eq $null
    }
$results.Total++; if ($search4.Success) { $results.Passed++ } else { $results.Failed++ }

# ====================================================
# 4. SIMULATION SHARING TESTS
# ====================================================
Write-Log "`n--- SIMULATION SHARING TESTS ---" "Yellow"

# Create a simulation
$simData = @{
    name = "Test Beam Simulation"
    supportType = "SIMPLY_SUPPORTED"
    materialType = "STEEL"
    loadType = "POINT_LOAD"
    loadMagnitude = 5000
    beamLength = 6.0
    beamWidth = 0.3
    beamHeight = 0.5
    isPublic = $false
} | ConvertTo-Json

$simCreate = Test-Api -Name "Create Simulation" `
    -Method POST -Endpoint "/simulations" `
    -Headers $headers1 `
    -Body $simData
$results.Total++; if ($simCreate.Success) { $results.Passed++ } else { $results.Failed++ }

$simId = $simCreate.Data.data.id

# Get my shares (should be empty)
$myShares1 = Test-Api -Name "Get My Shares (Empty)" `
    -Method GET -Endpoint "/shares/my-shares" `
    -Headers $headers1 `
    -Validation { param($c) return $c.data.Count -eq 0 }
$results.Total++; if ($myShares1.Success) { $results.Passed++ } else { $results.Failed++ }

# Share simulation with friend
if ($simId) {
    $share = Test-Api -Name "Share Simulation with Friend" `
        -Method POST -Endpoint "/shares?simulationId=$simId&friendId=$user2Id&permission=VIEW" `
        -Headers $headers1 `
        -Validation { param($c) return $c.success -eq $true }
    $results.Total++; if ($share.Success) { $results.Passed++ } else { $results.Failed++ }
    
    # Verify shares
    $myShares2 = Test-Api -Name "Get My Shares (After Share)" `
        -Method GET -Endpoint "/shares/my-shares" `
        -Headers $headers1 `
        -Validation { param($c) return $c.data.Count -eq 1 }
    $results.Total++; if ($myShares2.Success) { $results.Passed++ } else { $results.Failed++ }
    
    $sharedWithMe = Test-Api -Name "Get Shared With Me (User2)" `
        -Method GET -Endpoint "/shares/shared-with-me" `
        -Headers $headers2 `
        -Validation { param($c) return $c.data.Count -eq 1 }
    $results.Total++; if ($sharedWithMe.Success) { $results.Passed++ } else { $results.Failed++ }
}

# ====================================================
# 5. CHAT TESTS
# ====================================================
Write-Log "`n--- CHAT TESTS ---" "Yellow"

# Get conversations (should be empty)
$conv1 = Test-Api -Name "Get Conversations (Empty)" `
    -Method GET -Endpoint "/chat/conversations" `
    -Headers $headers1 `
    -Validation { param($c) return $c.data.Count -eq 0 }
$results.Total++; if ($conv1.Success) { $results.Passed++ } else { $results.Failed++ }

# Send a message
$msgData = @{
    receiverId = $user2Id
    content = "Hello from Hamza! This is a test message."
} | ConvertTo-Json

$sendMsg = Test-Api -Name "Send Chat Message" `
    -Method POST -Endpoint "/chat/send" `
    -Headers $headers1 `
    -Body $msgData `
    -Validation { param($c) return $c.data.content -eq "Hello from Hamza! This is a test message." }
$results.Total++; if ($sendMsg.Success) { $results.Passed++ } else { $results.Failed++ }

# Check unread count for User 2
$unread = Test-Api -Name "Get Unread Count (User2)" `
    -Method GET -Endpoint "/chat/unread" `
    -Headers $headers2 `
    -Validation { param($c) return $c.data -ge 1 }
$results.Total++; if ($unread.Success) { $results.Passed++ } else { $results.Failed++ }

# Get conversations after message
$conv2 = Test-Api -Name "Get Conversations (After Message)" `
    -Method GET -Endpoint "/chat/conversations" `
    -Headers $headers1 `
    -Validation { param($c) return $c.data.Count -ge 1 }
$results.Total++; if ($conv2.Success) { $results.Passed++ } else { $results.Failed++ }

# Get conversation messages
$convMsgs = Test-Api -Name "Get Conversation Messages" `
    -Method GET -Endpoint "/chat/conversation/$user2Id" `
    -Headers $headers1 `
    -Validation { param($c) return $c.data.Count -ge 1 }
$results.Total++; if ($convMsgs.Success) { $results.Passed++ } else { $results.Failed++ }

# Mark as read
$markRead = Test-Api -Name "Mark Messages as Read" `
    -Method POST -Endpoint "/chat/read/$user1Id" `
    -Headers $headers2
$results.Total++; if ($markRead.Success) { $results.Passed++ } else { $results.Failed++ }

# Verify unread is 0
$unread2 = Test-Api -Name "Verify Unread Count is 0" `
    -Method GET -Endpoint "/chat/unread" `
    -Headers $headers2 `
    -Validation { param($c) return $c.data -eq 0 }
$results.Total++; if ($unread2.Success) { $results.Passed++ } else { $results.Failed++ }

# ====================================================
# 6. CLEANUP / REMOVE FRIEND
# ====================================================
Write-Log "`n--- CLEANUP TESTS ---" "Yellow"

# Get friendship ID
$friendshipId = $friends2.Data.data[0].friendshipId

if ($friendshipId) {
    $remove = Test-Api -Name "Remove Friend" `
        -Method DELETE -Endpoint "/friends/$friendshipId" `
        -Headers $headers1
    $results.Total++; if ($remove.Success) { $results.Passed++ } else { $results.Failed++ }
    
    # Verify no more friends
    $friends4 = Test-Api -Name "Verify No Friends After Remove" `
        -Method GET -Endpoint "/friends" `
        -Headers $headers1 `
        -Validation { param($c) return $c.data.Count -eq 0 }
    $results.Total++; if ($friends4.Success) { $results.Passed++ } else { $results.Failed++ }
}

# ====================================================
# SUMMARY
# ====================================================
Write-Log "`n" + "=" * 60 "Cyan"
Write-Log "TEST SUMMARY" "Cyan"
Write-Log "=" * 60 "Cyan"
Write-Log "Total Tests: $($results.Total)" "White"
Write-Log "Passed: $($results.Passed)" "Green"
Write-Log "Failed: $($results.Failed)" "Red"
Write-Log "Success Rate: $([math]::Round(($results.Passed / $results.Total) * 100, 1))%" "Cyan"
Write-Log "`nLog saved to: $logFile" "Gray"

# Return exit code
if ($results.Failed -eq 0) {
    Write-Log "`n✅ ALL TESTS PASSED!" "Green"
    exit 0
} else {
    Write-Log "`n❌ SOME TESTS FAILED" "Red"
    exit 1
}
