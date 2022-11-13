#Requires -Version 5.0

[CmdletBinding(SupportsShouldProcess = $True)]
         
param 
(
  [Parameter(Mandatory = $True, Position = 0)]
  [ValidateNotNullOrEmpty()]
  [String]
  $svcAccount
)

Add-LocalGroupMember -Group "Administrators" -Member "$svcAccount"
