module icon

$if macos {
	#include <Cocoa/Cocoa.h>
	#flag -framework Cocoa
	#include "@VMODROOT/src/icon/icon.m"
} $else {
	$if linux {
		#pkgconfig gtk+-3.0
		#pkgconfig webkit2gtk-4.0
	}
	#flag -I@VMODROOT/src/icon
	#flag @VMODROOT/src/icon/icon.o
	#include "@VMODROOT/src/icon/icon.h"
}

enum SetIconErrorCode {
	ok
	icon_not_found
	window_not_found
	os_unsupported
}

fn C.set_icon(w voidptr, ico_file_path &char) SetIconErrorCode

// set_icon updates the icon of the native window. It supports Windows HWND windows and Linux GTK
// windows under X11 - under Wayland, window application mapping is based on the desktop file entry name.
// TODO: add macOS support
pub fn set_icon(window voidptr, icon_file_path string) ! {
	result := SetIconErrorCode(C.set_icon(window, &char(icon_file_path.str)))
	match result {
		.ok { return }
		.icon_not_found { return error('Failed finding icon.') }
		.window_not_found { return error('Failed to set icon. Window not found.') }
		.os_unsupported { return error('Failed to set icon. Unsupported OS.') }
	}
}
