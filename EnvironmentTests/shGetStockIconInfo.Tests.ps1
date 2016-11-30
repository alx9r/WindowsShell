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

    public static string GetIcon(int identifier)
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
    It 'get icon info' {
        $r = $h.Types[0]::GetIcon(83)
        $r | Should be 'C:\WINDOWS\system32\imageres.dll,-94'
    }
}

