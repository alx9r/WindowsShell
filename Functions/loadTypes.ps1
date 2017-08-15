
@(
    'shellLibraryType.ps1'
    'shellLibraryFolderType.ps1'
    'stockIconInfoType.ps1'
) |
% { . "$($PSCommandPath | Split-Path -Parent)\$_" }
