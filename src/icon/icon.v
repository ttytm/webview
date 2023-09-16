module icon

import builtin.wchar

#flag -I@VMODROOT/src/icon/c
#flag @VMODROOT/src/icon/c/icon.o
#include "icon.h"

$if linux {
	#pkgconfig gtk+-3.0
	#pkgconfig webkit2gtk-4.0
}

fn C.set_icon_win32(w voidptr, ico_file_path &wchar.Character) bool

fn C.set_icon_linux(w voidptr, ico_file_path &char) bool

// set_icon updates the icon of the native window. It supports Windows HWND windows and Linux GTK
// windows under X11 - under Wayland, window application mapping is based on the desktop file entry name.
// TODO: add macOS support
pub fn set_icon(window voidptr, icon_file_path string) ! {
	$if windows {
		if !C.set_icon_win32(window, wchar.from_string(icon_file_path)) {
			return error('Failed to set icon.')
		}
	} $else $if linux {
		if !C.set_icon_linux(window, &char(icon_file_path.str)) {
			return error('Failed to set icon.')
		}
	} $else {
		return error('Failed to set icon. Unsupported OS.')
	}
}
