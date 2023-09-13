#include "icon.h"

BOOL set_icon(const void *ptr, const wchar_t *iconFilePath)
{

    // Load the icon from the specified file
    HICON hIcon = LoadImageW(NULL, iconFilePath, IMAGE_ICON, 0, 0, LR_LOADFROMFILE);
    if (hIcon == NULL)
    {
        fprintf(stderr, "Failed to load icon from file!\n");
        return FALSE;
    }
    // Get the current application's main window using the application's title
    // This can be handled better, for instance using a pointer to webview to
    // get the application, but for now this works fine.
    //    HWND hwnd = FindWindowW(NULL, applicationTitle);

    HWND hwnd = ((const HWND *)ptr);
    if (hwnd == NULL)
    {
        DestroyIcon(hIcon);
        fprintf(stderr, "Failed to find the application window!\n");
        return FALSE;
    }
    // Set the application icon
    SendMessageW(hwnd, WM_SETICON, ICON_BIG, (LPARAM)hIcon);

    // Cleanup
    DestroyIcon(hIcon);
    return TRUE;
}
