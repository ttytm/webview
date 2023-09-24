#pragma once
#include "icon.h"
#include <Cocoa/Cocoa.h>

enum SetIconResult set_icon(const void *ptr, const char *iconFilePath) {
	NSWindow *window = (NSWindow *)ptr;
	if (window == nil) {
		return WINDOW_NOT_FOUND;
	}
	NSString *iconPath = [NSString stringWithUTF8String:iconFilePath];
	NSImage *iconImage = [[NSImage alloc] initWithContentsOfFile:iconPath];
	if (iconImage == nil) {
		return ICON_NOT_FOUND;
	}
	[window setMiniwindowImage:iconImage];
	return OK;
}
