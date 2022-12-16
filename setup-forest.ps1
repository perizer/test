#Requires -Version 5.0

[CmdletBinding(SupportsShouldProcess = $True)]

param 
(
  [Parameter(Mandatory = $True, Position = 0)]
  [ValidateNotNullOrEmpty()]
  [SecureString]
  $password,

  [Parameter(Mandatory = $True, Position = 1)]
  [ValidateNotNullOrEmpty()]
  [String]
  $domain,

  [Parameter(Mandatory = $True, Position = 2)]
  [ValidateNotNullOrEmpty()]
  [String]
  $domainNetBiosName
)

install-windowsfeature AD-Domain-Services -IncludeManagementTools

Write-Host "Starting Forest Setup"
Write-Output "Starting Forest Setup"

Install-ADDSForest `
-CreateDnsDelegation:$false `
-DatabasePath "C:\Windows\NTDS" `
-DomainMode "WinThreshold" `
-DomainName $domain `
-DomainNetbiosName $domainNetBiosName `
-ForestMode "WinThreshold" `
-InstallDns:$true `
-LogPath "C:\Windows\NTDS" `
-NoRebootOnCompletion:$true `
-SysvolPath "C:\Windows\SYSVOL" `
-Confirm:$false `
-Force:$true `
-SafeModeAdministratorPassword:$password

Write-Host "Restarting Computer"

Restart-Computer    
