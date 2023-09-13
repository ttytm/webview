#include "icon.h"

void set_window_icon(const wchar_t *applicationTitle, const wchar_t *iconFilePath)
{

    // Load the icon from the specified file
    HICON hIcon = LoadImageW(NULL, iconFilePath, IMAGE_ICON, 0, 0, LR_LOADFROMFILE);
    if (hIcon == NULL)
    {
        MessageBoxW(NULL, L"Failed to load icon from file!", L"Error", MB_ICONERROR);
    }
    // Get the current application's main window using the application's title
    // This can be handled better, for instance using a pointer to webview to
    // get the application, but for now this works fine.
    HWND hwnd = FindWindowW(NULL, applicationTitle);

    if (hwnd == NULL)
    {
        MessageBoxW(NULL, L"Failed to find the application window!", L"Error", MB_ICONERROR);
        DestroyIcon(hIcon);
    }
    // Set the application icon
    SendMessageW(hwnd, WM_SETICON, ICON_BIG, (LPARAM)hIcon);

    // Cleanup
    DestroyIcon(hIcon);
}
