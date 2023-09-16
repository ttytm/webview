#pragma once
#include <stdio.h>

#ifdef _WIN32
#include <tchar.h>
#include <windows.h>
BOOL set_icon_win32(const void *ptr, const wchar_t *iconFilePath);
#elif __linux__
#include <gtk/gtk.h>
#include <stdbool.h>
bool set_icon_linux(const void *ptr, const char *iconFilePath);
#endif
