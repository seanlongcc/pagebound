param(
    [string]$ProjectPath = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path,
    [string]$McpUrl = "http://127.0.0.1:8000/mcp",
    [int]$TimeoutSeconds = 60,
    [string]$GodotExe = $env:GODOT_EXE,
    [switch]$NoLaunch
)

$ErrorActionPreference = "Stop"

function Resolve-GodotExe {
    param([string]$ExplicitPath)

    $candidates = @()
    if ($ExplicitPath) {
        $candidates += $ExplicitPath
    }

    $command = Get-Command godot -ErrorAction SilentlyContinue
    if ($command -and $command.Source) {
        $candidates += $command.Source
    }

    $candidates += @(
        (Join-Path $HOME "Documents\Godot\Godot_v4.6.2-stable_win64.exe"),
        (Join-Path $HOME "Documents\Godot\Godot_v4.6.2-stable_win64_console.exe")
    )

    foreach ($candidate in $candidates) {
        if ($candidate -and (Test-Path $candidate)) {
            return (Resolve-Path $candidate).Path
        }
    }

    throw "Godot executable not found. Set GODOT_EXE to the Godot .exe path, then retry."
}

function Invoke-McpRequest {
    param(
        [hashtable]$Body,
        [string]$SessionId = ""
    )

    $headers = @{
        Accept = "application/json, text/event-stream"
    }
    if ($SessionId) {
        $headers["Mcp-Session-Id"] = $SessionId
    }

    $json = $Body | ConvertTo-Json -Depth 20 -Compress
    $response = Invoke-WebRequest `
        -Uri $McpUrl `
        -Method Post `
        -ContentType "application/json" `
        -Headers $headers `
        -Body $json `
        -TimeoutSec 10 `
        -UseBasicParsing

    return $response
}

function Read-SseJson {
    param([string]$Content)

    $dataLine = ($Content -split "`n" | Where-Object { $_ -like "data: *" } | Select-Object -First 1)
    if (-not $dataLine) {
        throw "MCP response did not contain SSE data."
    }

    return ($dataLine.Substring(6).Trim() | ConvertFrom-Json)
}

function Test-McpPort {
    try {
        $response = Invoke-WebRequest `
            -Uri $McpUrl `
            -Headers @{ Accept = "text/event-stream" } `
            -TimeoutSec 3 `
            -UseBasicParsing

        return $response.StatusCode -in @(200, 400, 406)
    }
    catch {
        $status = $_.Exception.Response.StatusCode.value__
        return $status -in @(400, 406)
    }
}

if (-not (Test-Path $ProjectPath)) {
    throw "Project path not found: $ProjectPath"
}

$ProjectPath = (Resolve-Path $ProjectPath).Path.TrimEnd("\", "/")
$projectPathForMatch = $ProjectPath.Replace("\", "/").ToLowerInvariant()

if (-not $NoLaunch) {
    $godot = Resolve-GodotExe $GodotExe
    $existingEditor = Get-CimInstance Win32_Process |
        Where-Object {
            $commandLine = ($_.CommandLine -as [string])
            $normalizedCommandLine = $commandLine.Replace("\", "/").ToLowerInvariant()
            $_.Name -like "Godot*" -and
            $commandLine -like "*--editor*" -and
            $normalizedCommandLine.Contains($projectPathForMatch)
        } |
        Select-Object -First 1

    if ($existingEditor) {
        Write-Host "Godot editor already running for project. PID: $($existingEditor.ProcessId)"
    }
    else {
        Write-Host "Starting Godot editor: $godot"
        Start-Process -FilePath $godot -ArgumentList @("--editor", "--path", $ProjectPath)
    }
}

$deadline = (Get-Date).AddSeconds($TimeoutSeconds)
do {
    if (Test-McpPort) {
        break
    }
    Start-Sleep -Seconds 1
} while ((Get-Date) -lt $deadline)

if (-not (Test-McpPort)) {
    throw "Godot AI MCP did not respond at $McpUrl within $TimeoutSeconds seconds."
}

$initialize = Invoke-McpRequest @{
    jsonrpc = "2.0"
    id = 1
    method = "initialize"
    params = @{
        protocolVersion = "2025-03-26"
        capabilities = @{}
        clientInfo = @{
            name = "pagebound-mcp-check"
            version = "1.0.0"
        }
    }
}

$sessionId = $initialize.Headers["mcp-session-id"]
if (-not $sessionId) {
    throw "MCP initialize response did not include mcp-session-id."
}

$initData = Read-SseJson $initialize.Content
Write-Host "MCP initialized. Server: $($initData.result.serverInfo.name) $($initData.result.serverInfo.version)"

[void](Invoke-McpRequest @{
    jsonrpc = "2.0"
    method = "notifications/initialized"
} $sessionId)

$stateResponse = Invoke-McpRequest @{
    jsonrpc = "2.0"
    id = 2
    method = "tools/call"
    params = @{
        name = "editor_state"
        arguments = @{}
    }
} $sessionId

$stateData = Read-SseJson $stateResponse.Content
$state = $stateData.result.structuredContent

Write-Host "Godot AI MCP ready."
Write-Host "Project: $($state.project_name)"
Write-Host "Godot: $($state.godot_version)"
Write-Host "Scene: $($state.current_scene)"
Write-Host "Readiness: $($state.readiness)"
Write-Host "Endpoint: $McpUrl"
