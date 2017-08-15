<#
WindowStyle Property

https://msdn.microsoft.com/fr-fr/library/w88k7fw2(v=vs.84).aspx

intWindowStyle  Description
1               Activates and displays a window. If the window is minimized
                or maximized, the system restores it to its original size and
                position.
3               Activates the window and displays it as a maximized window.
7               Minimizes the window and activates the next top-level window.
#>

Add-Type @'
public enum WindowStyle
{
    Normal = 1,
    Maximized = 3,
    Minimized = 7
}
'@