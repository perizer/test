#Requires -Version 5.0

[CmdletBinding(SupportsShouldProcess = $True)]
         
param 
(
  [Parameter(Mandatory = $True, Position = 0)]
  [ValidateNotNullOrEmpty()]
  [String]
  $svcAccount,

  [Parameter(Mandatory = $True, Position = 1)]
  [ValidateNotNullOrEmpty()]
  [String]
  $domain,

  [Parameter(Mandatory = $True, Position = 2)]
  [ValidateNotNullOrEmpty()]
  [String]
  $rootCertName,

  [Parameter(Position = 3)]
  [String]
  $interfaceAlias = "Ethernet0*"
)

Start-Transcript -Path C:\Temp\setupWinRm.log

W32tm /resync /force

Write-Host "Current Time: $(Get-Date -Format o)"

if (-not (Get-LocalGroupMember -Group "Administrators" -Member "*$($svcAccount)*" -ErrorAction SilentlyContinue)) {
  Add-LocalGroupMember -Group "Administrators" -Member "$svcAccount"
}

while ($count -le 30) {
  $existingCert = Get-ChildItem cert:\CurrentUser\My\ | Where-Object Subject -match $rootCertName 

  if (-not $existingCert) {
    $count++
    Start-Sleep -Seconds 1
  } else {
    break
  }

  if ($count -eq 30) {
    throw "Failed to find root certificate $rootCertName"
  }
}

$IP = (Get-NetIPAddress -InterfaceAlias $interfaceAlias -AddressFamily IPv4).IPAddress
$ShortName = "$($Env:COMPUTERNAME)"
$FQDN = "$($Env:COMPUTERNAME).$(($domain).ToLower())"

$StopLoop = $false
$RetryCount = 0

do {
  try {
    $Cert = Get-Certificate -Template WebServerExportPrivate -DnsName $IP,$ShortName,$FQDN -SubjectName "CN=$($FQDN)" -CertStoreLocation 'cert:\CurrentUser\My\'
    $StopLoop = $true
  }
  catch {
    if ($RetryCount -gt 5) {
      Write-Host "Could not get certificate after 5 retries."
      $StopLoop = $true
    } else {
      Write-Host "Could not get certificate, retrying in 30 seconds..."
      Start-Sleep -Seconds 30
      $RetryCount = $RetryCount + 1
    }
  }
}
while ($StopLoop -eq $false)

$CertificateThumbprint = $Cert.Certificate.Thumbprint

$listener = @{
   ResourceURI = "winrm/config/Listener"
   SelectorSet = @{Address="*";Transport="HTTPS"}
   ValueSet = @{CertificateThumbprint=$CertificateThumbprint}
 }
 
 Set-WSManInstance @listener

 Stop-Transcript
