#pragma once

#ifdef _WIN32
#include "wchar.h"
#include <windows.h>
#elif __linux__
#include <gtk/gtk.h>
#endif

enum SetIconResult {
   OK = 0,
   WINDOW_NOT_FOUND,
   ICON_NOT_FOUND,
   OS_UNSUPPORTED,
};

#ifndef __APPLE__
enum SetIconResult set_icon(const void *ptr, const char *iconFilePath);
#endif
