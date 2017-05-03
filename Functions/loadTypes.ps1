
@(
    'shellLibraryType.ps1'
    'stockIconInfoType.ps1'
    'shortcutType.ps1'
) |
% { . "$($PSCommandPath | Split-Path -Parent)\$_" }
