# load the assembly
Add-type -Path ..\bin\winapicp\Microsoft.WindowsAPICodePack.Shell.dll

# Get the libraries
$libraries = [Microsoft.WindowsAPICodePack.Shell.KnownFolders]::Libraries 

# List existing library names
$libraries |% Name

$libraryName = 'MyShellLibrary'
$overwrite = $false
$readonly = $false
# Create a new library
[Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::new($libraryName,$overwrite)

# Get the new libary
$library = [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::Load($libraryName,$readonly)

# Set the library type
$library.LibraryType = [Microsoft.WindowsAPICodePack.Shell.LibraryFolderType]::Pictures

# Get the music icon resource id
$musicIconResourceId =  [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::Load('Music',$true).IconResourceId

# set the library's icon to music icon
$library.IconResourceId = $musicIconResourceId

$folderPath = 'C:\Users'

# Add a folder to the library
$library.Add($folderPath)

# List existing folder names
$library | % Name

# Remove the folder from the Library
$library.Remove($folderPath)

# Delete the shell library

$librariesPath = [System.IO.Path]::Combine(
    [System.Environment]::GetFolderPath( [System.Environment+SpecialFolder]::ApplicationData ),
    [Microsoft.WindowsAPICodePack.Shell.ShellLibrary]::LibrariesKnownFolder.RelativePath
)
$libraryPath = [System.IO.Path]::Combine($librariesPath, $libraryName);
$libraryFullPath = [System.IO.Path]::ChangeExtension($libraryPath, "library-ms")
[System.IO.File]::Delete($libraryFullPath)