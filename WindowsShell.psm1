$modulePath = ($PSCommandPath | Split-Path -Parent)

# load the Windows API Code Pack Assembly
Add-Type -Path "$modulePath\bin\winapicp\Microsoft.WindowsAPICodePack.Shell.dll"
