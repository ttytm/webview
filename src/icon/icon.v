module icon

#flag -I@VMODROOT/src/icon/c
#flag @VMODROOT/src/icon/c/icon.o
#include "@VMODROOT/src/icon/c/icon.h"

$if linux {
	#pkgconfig gtk+-3.0
	$if $pkgconfig('webkit2gtk-4.1') {
		#pkgconfig webkit2gtk-4.1
	} $else {
		#pkgconfig webkit2gtk-4.0
	}
}

enum SetIconResult {
	ok               = C.OK
	window_not_found = C.WINDOW_NOT_FOUND
	icon_not_found   = C.ICON_NOT_FOUND
	os_unsupported   = C.OS_UNSUPPORTED
}

fn C.set_icon(w voidptr, ico_file_path &char) SetIconResult

// set_icon updates the icon of the native window. It supports Windows HWND windows and Linux GTK
// windows under X11 - under Wayland, window application mapping is based on the desktop file entry name.
// TODO: add macOS support
pub fn set_icon(window voidptr, icon_file_path string) ! {
	result := SetIconResult(C.set_icon(window, &char(icon_file_path.str)))
	match result {
		.ok { return }
		.icon_not_found { return error('Failed to find icon at `${icon_file_path}`.') }
		.window_not_found { return error('Failed to set icon. Window not found.') }
		// .os_unsupported { return error('Failed to set icon. Unsupported OS.') }
		.os_unsupported { return }
	}
}
