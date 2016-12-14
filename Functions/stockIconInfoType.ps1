$code = @'
    [StructLayoutAttribute(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
    private struct _StockIconInfo
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
        _StockIconInfo info = new _StockIconInfo();
        info.StuctureSize = (UInt32)System.Runtime.InteropServices.Marshal.SizeOf(typeof(_StockIconInfo));

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
        ref _StockIconInfo info);
'@

$splat = @{
    MemberDefinition = $code
    Name = 'StockIconInfo'
    NameSpace = 'StockIconInfo'
}
Add-Type @splat | Out-Null
