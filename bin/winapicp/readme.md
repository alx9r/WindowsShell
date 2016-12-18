## Windows API Code Pack

There doesn't seem to be an official Microsoft source for the Windows API Code pack.  The following links seem to be the most canonical resources: 

* [stackoverflow.com: Windows API Code Pack: Where is it?](https://stackoverflow.com/questions/24081665/windows-api-code-pack-where-is-it)
* [github.com/aybe/Windows-API-Code-Pack-1.1](https://github.com/aybe/Windows-API-Code-Pack-1.1)
* [github.com/alx9r/Windows-API-Code-Pack-1.1](https://github.com/alx9r/Windows-API-Code-Pack-1.1)
* [Windows API Code Pack Help.chm](https://raw.githubusercontent.com/alx9r/Windows-API-Code-Pack-1.1/ae73c1294fe9d47c5052d090b945f69a6364e3a8/documentation/Windows%20API%20Code%20Pack%20Help.chm)

### Nuget Packages

Binaries from github.com/aybe/Windows-API-Code-Pack-1.1 seem to be distributed as nuget packages.  These are the two of interest for this module:

* [WindowsAPICodePack-Core](https://www.nuget.org/packages/WindowsAPICodePack-Core)
* [WindowsAPICodePack-Shell](https://www.nuget.org/packages/WindowsAPICodePack-Shell/)

### How the Binaries Were Obtained

This project uses two .dll files from the Windows API Code pack:
`Microsoft.WindowsAPICodePack.dll` and `Microsoft.WindowsAPICodePack.Shell.dll`.  These two binaries are distributed with the WindowsShell module in the `\bin\winapicp` folder.  The binaries were obtained by the following steps:

1. `Save-package -name WindowsAPICodePack-Core,WindowsAPICodePack-Shell -provider Nuget -source https://www.nuget.org/api/v2 -Path .` - This downloads two files: `WindowsAPICodePack-Core.1.1.2.nupkg` and `WindowsAPICodePack-Shell.1.1.1.nupkg`
2. Extract the files in `\lib` from the `.nupkg` files to this folder.