enum Ensure
{
    Present
    Absent
}

enum WindowStyle
{
    Normal = 1
    Maximized = 3
    Minimized = 7
}

enum StockIconName
{
    DocumentNotAssociated; DocumentAssociated; Application; Folder; FolderOpen; Drive525; Drive35; DriveRemove; 
    DriveFixed; DriveNetwork; DriveNetworkDisabled; DriveCD; DriveRam; World; Server; Printer; MyNetwork; Find; Help; 
    Share; Link; SlowFile; Recycler; RecyclerFull; MediaCDAudio; Lock; AutoList; PrinterNet; ServerShare; PrinterFax; 
    PrinterFaxNet; PrinterFile; Stack; MediaSvcd; StuffedFolder; DriveUnknown; DriveDvd; MediaDvd; MediaDvdRam; 
    MediaDvdRW; MediaDvdR; MediaDvdRom; MediaCDAudioPlus; MediaCDRW; MediaCDR; MediaCDBurn; MediaBlankCD; MediaCDRom; 
    AudioFiles; ImageFiles; VideoFiles; MixedFiles; FolderBack; FolderFront; Shield; Warning; Info; Error; Key; 
    Software; Rename; Delete; MediaAudioDvd; MediaMovieDvd; MediaEnhancedCD; MediaEnhancedDvd; MediaHDDvd; 
    MediaBluRay; MediaVcd; MediaDvdPlusR; MediaDvdPlusRW; DesktopPC; MobilePC; Users; MediaSmartMedia; 
    MediaCompactFlash; DeviceCellPhone; DeviceCamera; DeviceVideoCamera; DeviceAudioPlayer; NetworkConnect; Internet; 
    ZipFile; Settings; DriveHDDVD; DriveBluRay; MediaHDDVDROM; MediaHDDVDR; MediaHDDVDRAM; MediaBluRayROM; 
    MediaBluRayR; MediaBluRayRE; ClusteredDisk;

    DoNotSet
}

[DscResource()]
class Shortcut
{
    [DscProperty(Key)]
    [string]
    $Path

    [DscProperty()]
    [Ensure]
    $Ensure

    [DscProperty()]
    [string]
    $TargetPath

    [DscProperty()]
    [string]
    $Arguments

    [DscProperty()]
    [string]
    $WorkingDirectory

    [DscProperty()]
    [WindowStyle]
    $WindowStyle=[WindowStyle]::Normal

    [DscProperty()]
    [string]
    $Hotkey

    [DscProperty()]
    [StockIconName]
    $StockIconName = [StockIconName]::DoNotSet

    [DscProperty()]
    [string]
    $IconFilePath

    [DscProperty()]
    [int]
    $IconResourceId

    [DscProperty()]
    [string]
    $Description

    [void] Set() { 
        $this | Invoke-ProcessShortcut Set
    }
    [bool] Test() { 
        return $this | Invoke-ProcessShortcut Test 
    }

    [Shortcut] Get() { return $this }
}  