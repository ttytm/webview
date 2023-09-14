#pragma once
#include <stdio.h>

#ifdef _WIN32
#include <windows.h>
#include <tchar.h>
BOOL set_icon_win32(const void *ptr, const wchar_t *iconFilePath);
#else
#include <gtk/gtk.h>
#include <stdbool.h>
bool set_icon_linux(const void *ptr, const char *iconFilePath);
#endif
