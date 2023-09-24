#pragma once
#include <stdio.h>

#ifdef _WIN32
#include <windows.h>
#elif __linux__
#include <gtk/gtk.h>
#endif

#ifndef __APPLE__
enum SetIconResult set_icon(const void *ptr, const char *iconFilePath);
#endif

enum SetIconResult {
	OK = 0,
	ICON_NOT_FOUND,
	WINDOW_NOT_FOUND,
	OS_UNSUPPORTED,
};
