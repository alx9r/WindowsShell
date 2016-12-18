enum Ensure
{
    Present
    Absent
}

enum LibraryTypeName
{
    Generic
    Documents
    Music
    Pictures
    Videos

    DoNotSet
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
class ShellLibrary
{
    [DscProperty(Key)]
    [string]
    $Name

    [DscProperty()]
    [Ensure]
    $Ensure

    [DscProperty()]
    [LibraryTypeName]
    $TypeName = [LibraryTypeName]::DoNotSet

    [DscProperty()]
    [StockIconName]
    $StockIconName = [StockIconName]::DoNotSet

    [DscProperty()]
    [string]
    $IconFilePath

    [DscProperty()]
    [int]
    $IconResourceId

    [void] Set() { $this | Invoke-ProcessShellLibrary Set }
    [bool] Test() { return $this | Invoke-ProcessShellLibrary Test }

    [ShellLibrary] Get() { return $this }
}  