param(
  [string]$ProxyUrl = "http://127.0.0.1:7897",
  [string]$NoProxy = "localhost,127.0.0.1,::1,.local",
  [switch]$ApplyWinHttp,
  [switch]$Clear
)

$ErrorActionPreference = "Stop"

function Set-UserEnv {
  param(
    [string]$Name,
    [string]$Value
  )

  [Environment]::SetEnvironmentVariable($Name, $Value, "User")
  [Environment]::SetEnvironmentVariable($Name, $Value, "Process")
}

function Clear-UserEnv {
  param([string]$Name)

  [Environment]::SetEnvironmentVariable($Name, $null, "User")
  [Environment]::SetEnvironmentVariable($Name, $null, "Process")
}

$proxyNames = @(
  "HTTP_PROXY",
  "HTTPS_PROXY",
  "ALL_PROXY",
  "http_proxy",
  "https_proxy",
  "all_proxy"
)

$noProxyNames = @(
  "NO_PROXY",
  "no_proxy"
)

if ($Clear) {
  foreach ($name in $proxyNames + $noProxyNames) {
    Clear-UserEnv -Name $name
  }
  Write-Host "ok: cleared user proxy environment variables"
} else {
  foreach ($name in $proxyNames) {
    Set-UserEnv -Name $name -Value $ProxyUrl
  }
  foreach ($name in $noProxyNames) {
    Set-UserEnv -Name $name -Value $NoProxy
  }
  Write-Host "ok: set user proxy environment variables to $ProxyUrl"
  Write-Host "ok: set NO_PROXY to $NoProxy"
}

if ($ApplyWinHttp) {
  if ($env:OS -ne "Windows_NT") {
    Write-Warning "not running on Windows; skipping WinHTTP"
    exit 0
  }

  if ($Clear) {
    netsh winhttp reset proxy
  } else {
    $uri = [Uri]$ProxyUrl
    $hostPort = "$($uri.Host):$($uri.Port)"
    netsh winhttp set proxy "http=$hostPort;https=$hostPort" "localhost;127.0.0.1;*.local"
  }
}

Write-Host "ok: open a new PowerShell or terminal window before launching CLI tools"

