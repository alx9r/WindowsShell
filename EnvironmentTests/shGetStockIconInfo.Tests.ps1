Describe 'set up environment' {
    It 'add the Windows API Code Pack assembly' {
        Add-Type -Path "$PSScriptRoot\..\bin\winapicp\Microsoft.WindowsAPICodePack.Shell.dll"
    }
}
Describe 'P/Invoke SHGetStockIconInfo' {
    # adapted from https://github.com/kyzmitch/Cip/blob/357a9fd16552310d571b99a381922d6e0e059d76/Demo/Libraries/Windows7.DesktopIntegration.LibraryManagerDemo/LibraryManager.cs#L396-L449
    $pinvokerCode = @'
    [StructLayoutAttribute(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
    private struct StockIconInfo
    {
        internal UInt32 StuctureSize;
        internal IntPtr Handle;
        internal Int32 ImageIndex;
        internal Int32 Identifier;
        [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 260)]
        internal string Path;
    }

    public static string GetIconRefPath(int identifier)
    {
        StockIconInfo info = new StockIconInfo();
        info.StuctureSize = (UInt32)System.Runtime.InteropServices.Marshal.SizeOf(typeof(StockIconInfo));

        int hResult = SHGetStockIconInfo(identifier, 0, ref info);

        if (hResult != 0)
            throw new System.ComponentModel.Win32Exception("SHGetStockIconInfo execution failure " + hResult.ToString());

        return info.Path + "," + info.Identifier;
    }

    [DllImport("Shell32.dll", CharSet = CharSet.Unicode,
    ExactSpelling = true, SetLastError = false)]
    private static extern int SHGetStockIconInfo(
        int identifier,
        int flags,
        ref StockIconInfo info);
'@
    $h = @{}
    It 'add the type(s)' {
        $splat = @{
            MemberDefinition = $pinvokerCode
            Name = 'PInvoker'
            NameSpace = 'PInvoker'
        }
        $h.Types = Add-Type @splat -PassThru
        $h.Types.Count | Should be 2
        $h.Types[0].Name | Should be 'PInvoker'
    }
    It 'GetIcon() returns exactly one string object' {
        $r = [PInvoker.PInvoker]::GetIconRefPath(83)
        $r.Count | Should be 1
        $r | Should beOfType string
    }
    It 'get an ID for a known icon' {
        $r = [int][Microsoft.WindowsAPICodePack.Shell.StockIconIdentifier]::World
        $r | Should be '13'
    }
    It 'get icon info for the known icon' {
        $r = [PInvoker.PInvoker]::GetIconRefPath(13)
        $r | Should be 'C:\WINDOWS\system32\imageres.dll,-152'
    }
}

