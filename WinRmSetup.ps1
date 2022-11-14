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

$listener = @{
   ResourceURI = "winrm/config/Listener"
   SelectorSet = @{Address="*";Transport="HTTP"}
 }
 
Set-WSManInstance @listener
