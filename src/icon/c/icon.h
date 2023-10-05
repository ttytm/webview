#pragma once

#ifdef _WIN32
#include <windows.h>
#include <wchar.h>
#include <stdlib.h>
#elif __linux__
#include <gtk/gtk.h>
#endif

enum SetIconErrorCode {
   OK = 0,
   WINDOW_NOT_FOUND,
   ICON_NOT_FOUND,
   OS_UNSUPPORTED,
};

enum SetIconErrorCode set_icon(const void *ptr, const char *iconFilePath);
