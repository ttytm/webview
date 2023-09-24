#include "icon.h"

enum SetIconResult set_icon(const void *ptr, const char *iconFilePath) {

#ifdef _WIN32

	HWND hwnd = ((const HWND *)ptr);
	if (hwnd == NULL) {
		return WINDOW_NOT_FOUND;
	}
	HICON hIcon = LoadImageW(NULL, iconFilePath, IMAGE_ICON, 0, 0, LR_LOADFROMFILE);
	if (hIcon == NULL) {
		return ICON_NOT_FOUND;
	}
	// Set the application icon
	SendMessageW(hwnd, WM_SETICON, ICON_BIG, (LPARAM)hIcon);
	// Cleanup
	DestroyIcon(hIcon);
	return OK;

#elif __linux__

	GtkWidget *window = (GtkWidget *)ptr;
	if (window == NULL) {
		return WINDOW_NOT_FOUND;
	}
	GdkPixbuf *pixbuf = gdk_pixbuf_new_from_file(iconFilePath, NULL);
	if (pixbuf == NULL) {
		return ICON_NOT_FOUND;
	}
	GtkWindow *gtkWindow = GTK_WINDOW(window);
	gtk_window_set_icon(GTK_WINDOW(gtkWindow), pixbuf);
	g_object_unref(pixbuf);
	return OK;

#endif

	return OS_UNSUPPORTED;
}
