#include "icon.h"

#ifdef _WIN32
BOOL set_icon_win32(const void *ptr, const wchar_t *iconFilePath) {
	HICON hIcon = LoadImageW(NULL, iconFilePath, IMAGE_ICON, 0, 0, LR_LOADFROMFILE);
	if (hIcon == NULL) {
		fprintf(stderr, "Failed to load icon from file!\n");
		return FALSE;
	}
	HWND hwnd = ((const HWND *)ptr);
	if (hwnd == NULL) {
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
#elif __linux__
bool set_icon_linux(const void *ptr, const char *iconFilePath) {
	GtkWidget *window = (GtkWidget *)ptr;
	if (window == NULL) {
		fprintf(stderr, "Failed to find the application window!\n");
		return false;
	}
	GdkPixbuf *pixbuf = gdk_pixbuf_new_from_file(iconFilePath, NULL);
	if (pixbuf == NULL) {
		fprintf(stderr, "Failed to load icon from file!\n");
		return false;
	}
	GtkWindow *gtkWindow = GTK_WINDOW(window);
	gtk_window_set_icon(GTK_WINDOW(gtkWindow), pixbuf);
	g_object_unref(pixbuf);
	return true;
}
#endif
