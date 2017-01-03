# Getting Started with WindowsShell

## New to PowerShell or DSC?
All of the WindowsShell documentation assumes that you have a working familiarity with PowerShell.  Some of the documentation assumes a working familiarity with DSC and ZeroDSC.  If you are new to PowerShell, DSC, or ZeroDSC I recommend reviewing the getting started documentation at the [PowerShell](https://github.com/PowerShell/PowerShell) and [ZeroDSC](https://github.com/alx9r/ZeroDSC/tree/master/Docs/getting-started/readme.md) projects.

## Installing WindowsShell

WindowsShell is a PowerShell module.  To install simply put the root folder (the one named "WindowsShell") in one of the `$PSModulePath` folders on your system.  For testing and development I recommend installing WindowsShell to the user modules folder (usually `$Env:UserProfile\Documents\WindowsPowerShell\Modules`). 

### Prerequisites

WindowsShell requires WMF 5.0 or later.

### Obtaining WindowsShell

To obtain WindowsShell I recommend cloning [the repository](https://github.com/alx9r/WindowsShell.git) to your computer and checking out the [latest release](https://github.com/alx9r/WindowsShell/releases/latest) using `git clone` and `git checkout`.

Alternatively you can download then extract an archive of the module from [this page](https://github.com/alx9r/WindowsShell/releases/latest).

### Confirming Installation

To confirm that WindowsShell is installed on your computer, invoke the following commands:

```
C:\> Import-Module WindowsShell
C:\> Get-Module WindowsShell
ModuleType Version    Name                                ExportedCommands
---------- -------    ----                                ----------------
Script     0.1.0      WindowsShell                        {Add-ShellLibrary, ...

```

You should see some details about the WindowsShell module output by the `Get-Module` command as shown above.

## Configuring Windows Shell Libraries

The WindowsShell modules implements two interfaces for configuring shell libraries:

 * the PowerShell commands `Invoke-ProcessShellLibrary` and `Invoke-ProcessShellLibraryFolder`
 * the DSC resources `ShellLibrary` and `ShellLibraryFolders`  

### Commands

The following commands create a Shell Library called "PowerShell Modules", confirm that it was created, then add a folder to it.

```PowerShell
Invoke-ProcessShellLibrary Set Present 'PowerShell Modules'
if ( Invoke-ProcessShellLibrary Test Present 'PowerShell Modules' )
{
    Invoke-ProcessShellLibraryFolder Set Present 'PowerShell Modules' "$env:ProgramFiles\WindowsPowerShell\Modules"
}
```

The results can be observed using Windows Explorer:

<img src="https://cloud.githubusercontent.com/assets/11237922/21626091/06f535d2-d1c4-11e6-9c14-293cd691996c.png" alt="windows explorer showing shell library" width="400">

### DSC Resources

The following ZeroDSC commands create a Shell Library called "PSModulePath" and add all of the folders in PSModulePath to that library:

```PowerShell
$document = {
    Get-DscResource -Module WindowsShell | Import-DscResource

    $i = 0
    foreach ( $path in $env:PSModulePath.Split(';') )
    {
        $i ++
        ShellLibraryFolder $i @{
            FolderPath = $path
            LibraryName = 'PSModulePath'
            DependsOn = '[ShellLibrary]PSModulePath'
        }
    }

    ShellLibrary PSModulePath @{
        Name = 'PSModulePath'
        IconFilePath = $iconPath = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe"
    }
}

$instructions = ConfigInstructions PSModulePathLibrary $document
$instructions | Invoke-ConfigStep
```

The results can be observed using Windows Explorer:

<img src="https://cloud.githubusercontent.com/assets/11237922/21626097/0ec40518-d1c4-11e6-81cc-3e7ed34e6bee.png" alt="windows explorer showing shell library" width="600">

## Feedback

If you have feedback, encounter problems, or have a contribution please open an issue or pull request in [the WindowsShell Github repository](https://github.com/alx9r/WindowsShell).
