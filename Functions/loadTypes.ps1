
@(
    'shellLibraryType.ps1'
    'stockIconInfoType.ps1'
) |
% { . "$($PSCommandPath | Split-Path -Parent)\$_" }
