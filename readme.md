[![Build status](https://ci.appveyor.com/api/projects/status/t5dxe0l2nlcbbgtg/branch/master?svg=true&passingText=master%20-%20OK)](https://ci.appveyor.com/project/alx9r/WindowsShell/branch/master)

# WindowsShell

WindowsShell is a PowerShell module for configuring the Window Shell Libraries.

# Use

Configure Windows Shell Libraries like this

[image]

using straightforward PowerShell commands like this

```PowerShell
PS C:\> $iconPath = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe"
PS C:\> Invoke-ProcessShellLibrary Set Present 'PSModulePath' -IconFilePath $iconPath
```

# Getting Started

You can find the getting started documentation [here][].  

[here]: Docs/getting-started

# Roadmap

:white_large_square: = *on the WindowsShell roadmap* :heavy_check_mark: = *already implemented*

:heavy_check_mark: Commands to add, remove, and set attributes of Windows Shell Libraries and Shell Library Folders.

:heavy_check_mark: Setting Windows Shell Library folder icons from the Windows stock icons library.

:heavy_check_mark: Setting Windows Shell Library folder icons from resources in executable and .dll files.

:heavy_check_mark: DSC resources to add, remove, and set attributes of Windows Shell Libraries and Shell Library Folders.

:white_large_square: Re-order Windows Shell Libraries and Shell Library Folders.