param(
  [string]$ProxyUrl = $(if ($env:CLASH_PROXY_URL) { $env:CLASH_PROXY_URL } else { "http://127.0.0.1:7897" }),
  [string]$AnthropicUrl = $(if ($env:ANTHROPIC_CHECK_URL) { $env:ANTHROPIC_CHECK_URL } else { "https://api.anthropic.com/" }),
  [string]$IpCheckUrl = $(if ($env:IP_CHECK_URL) { $env:IP_CHECK_URL } else { "https://api.ipify.org" })
)

$ErrorActionPreference = "Stop"

function Write-Ok {
  param([string]$Message)
  Write-Host "ok: $Message"
}

function Write-Warn {
  param([string]$Message)
  Write-Warning $Message
}

function Fail {
  param([string]$Message)
  Write-Error $Message
  exit 1
}

function Get-NullDevice {
  if ($env:OS -eq "Windows_NT") {
    return "NUL"
  }
  return "/dev/null"
}

function Require-CurlExe {
  $curl = Get-Command curl.exe -ErrorAction SilentlyContinue
  if (-not $curl) {
    Fail "curl.exe was not found. Install a current Windows build or add curl.exe to PATH."
  }
  return $curl.Source
}

function Invoke-Curl {
  param([string[]]$Arguments)
  $curl = Require-CurlExe
  $output = & $curl @Arguments 2>&1
  $code = $LASTEXITCODE
  return [pscustomobject]@{
    Code = $code
    Output = ($output -join "`n").Trim()
  }
}

function Check-ProxyIp {
  $result = Invoke-Curl @(
    "-4", "-sS",
    "--connect-timeout", "8",
    "--max-time", "15",
    "--proxy", $ProxyUrl,
    $IpCheckUrl
  )

  if ($result.Code -ne 0 -or [string]::IsNullOrWhiteSpace($result.Output)) {
    Fail "could not fetch exit IP through $ProxyUrl. $($result.Output)"
  }

  Write-Ok "exit IP through ${ProxyUrl}: $($result.Output)"
}

function Check-Anthropic {
  $nullDevice = Get-NullDevice
  $result = Invoke-Curl @(
    "-4", "-sS",
    "-o", $nullDevice,
    "--connect-timeout", "8",
    "--max-time", "15",
    "--proxy", $ProxyUrl,
    "-w", "%{http_code}",
    $AnthropicUrl
  )

  if ($result.Output -match "^(200|301|302|400|401|403|404)$") {
    Write-Ok "Anthropic endpoint reachable through $ProxyUrl with HTTP $($result.Output)"
    return
  }

  Fail "Anthropic endpoint check returned HTTP '$($result.Output)' through $ProxyUrl"
}

function Check-DirectIpv6Shape {
  $nullDevice = Get-NullDevice
  $result = Invoke-Curl @(
    "-6", "-sS",
    "-o", $nullDevice,
    "--noproxy", "*",
    "--connect-timeout", "5",
    "--max-time", "8",
    "-w", "remote_ip=%{remote_ip} http=%{http_code}",
    $AnthropicUrl
  )

  if ($result.Code -ne 0 -or [string]::IsNullOrWhiteSpace($result.Output)) {
    Write-Ok "direct IPv6 probe failed or is unavailable"
    return
  }

  if ($result.Output -match "remote_ip=::ffff:198\.(18|19)\.") {
    Write-Ok "direct IPv6 probe only returned Mihomo fake-ip mapping: $($result.Output)"
    return
  }

  Write-Warn "direct IPv6 probe returned: $($result.Output)"
  Write-Warn "If this is a public IPv6 path, disable or route IPv6 intentionally before using Claude Guard."
}

function Show-UserProxyEnvironment {
  Write-Ok "process proxy environment:"
  foreach ($name in @("HTTP_PROXY", "HTTPS_PROXY", "ALL_PROXY", "NO_PROXY", "http_proxy", "https_proxy", "all_proxy", "no_proxy")) {
    $value = [Environment]::GetEnvironmentVariable($name, "Process")
    Write-Host "  ${name}=$value"
  }

  Write-Ok "user proxy environment:"
  foreach ($name in @("HTTP_PROXY", "HTTPS_PROXY", "ALL_PROXY", "NO_PROXY", "http_proxy", "https_proxy", "all_proxy", "no_proxy")) {
    $value = [Environment]::GetEnvironmentVariable($name, "User")
    Write-Host "  ${name}=$value"
  }
}

function Show-WindowsProxyState {
  if ($env:OS -ne "Windows_NT") {
    Write-Warn "not running on Windows; skipping Windows proxy registry and WinHTTP checks"
    return
  }

  Write-Ok "Windows user proxy registry:"
  $path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings"
  $props = Get-ItemProperty -Path $path -ErrorAction SilentlyContinue
  if ($props) {
    Write-Host "  ProxyEnable=$($props.ProxyEnable)"
    Write-Host "  ProxyServer=$($props.ProxyServer)"
    Write-Host "  ProxyOverride=$($props.ProxyOverride)"
  } else {
    Write-Warn "could not read Windows Internet Settings registry"
  }

  $netsh = Get-Command netsh.exe -ErrorAction SilentlyContinue
  if ($netsh) {
    Write-Ok "WinHTTP proxy:"
    & $netsh.Source winhttp show proxy
  } else {
    Write-Warn "netsh.exe not found; skipping WinHTTP proxy check"
  }
}

Write-Ok "using proxy: $ProxyUrl"
Check-ProxyIp
Check-Anthropic
Check-DirectIpv6Shape
Show-UserProxyEnvironment
Show-WindowsProxyState
Write-Ok "all Windows network checks completed"

