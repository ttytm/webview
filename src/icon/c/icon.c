#include "icon.h"

enum SetIconErrorCode set_icon(const void* ptr, const char* iconFilePath) {

#ifdef _WIN32

	HWND window = (HWND)ptr;
	if (window == NULL) {
		return WINDOW_NOT_FOUND;
	}
	size_t size = strlen(iconFilePath) + 1;
	wchar_t* iconPath = malloc(size * sizeof(wchar_t));
	mbstowcs(iconPath, iconFilePath, size);
	HICON hIcon = LoadImageW(NULL, iconPath, IMAGE_ICON, 0, 0, LR_LOADFROMFILE);
	if (hIcon == NULL) {
		free(iconPath);
		return ICON_NOT_FOUND;
	}
	// Set the application icon
	SendMessageW(window, WM_SETICON, ICON_BIG, (LPARAM)hIcon);
	// Cleanup
	free(iconPath);
	DestroyIcon(hIcon);
	return OK;

#elif __linux__

	GtkWidget* window = (GtkWidget*)ptr;
	if (window == NULL) {
		return WINDOW_NOT_FOUND;
	}
	GdkPixbuf* pixbuf = gdk_pixbuf_new_from_file(iconFilePath, NULL);
	if (pixbuf == NULL) {
		return ICON_NOT_FOUND;
	}
	GtkWindow* gtkWindow = GTK_WINDOW(window);
	gtk_window_set_icon(GTK_WINDOW(gtkWindow), pixbuf);
	g_object_unref(pixbuf);
	return OK;

#endif

	return OS_UNSUPPORTED;
}
