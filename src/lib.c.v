module webview

import builtin.wchar

#flag linux -DWEBVIEW_GTK -lstdc++
#flag darwin -DWEBVIEW_COCOA -framework WebKit -stdlib=libc++ -lstdc++
#flag windows -DWEBVIEW_EDGE -static -ladvapi32 -lole32 -lshell32 -lshlwapi -luser32 -lversion -lstdc++

#flag -I @VMODROOT/src/icon/icon.h
#flag @VMODROOT/src/icon/icon.c

#flag @VMODROOT/src/webview.o
#include "@VMODROOT/src/webview.h"
#include "@VMODROOT/src/icon/icon.h"

$if linux {
	#pkgconfig gtk+-3.0
	#pkgconfig webkit2gtk-4.0
}

struct C.webview_t {}

fn C.webview_create(debug int, window voidptr) &C.webview_t

fn C.webview_destroy(w &C.webview_t)

fn C.webview_run(w &C.webview_t)

fn C.webview_terminate(w &C.webview_t)

fn C.webview_dispatch(w &C.webview_t, func fn (w &C.webview_t, ctx voidptr), ctx voidptr)

fn C.webview_get_window(w &C.webview_t) voidptr

fn C.set_icon_win32(w voidptr, ico_file_path &wchar.Character) bool

fn C.set_icon_linux(w voidptr, ico_file_path &char) bool

fn C.webview_set_title(w &C.webview_t, title &char)

fn C.webview_set_size(w &C.webview_t, width int, height int, hints int)

fn C.webview_navigate(w &C.webview_t, url &char)

fn C.webview_set_html(w &C.webview_t, html &char)

fn C.webview_init(w &C.webview_t, code &char)

fn C.webview_eval(w &C.webview_t, code &char)

fn C.webview_bind(w &C.webview_t, func_name &char, func fn (event_id &char, args &char, ctx voidptr), ctx voidptr)

fn C.webview_unbind(w &C.webview_t, func_name &char)

fn C.webview_return(w &C.webview_t, event_id &char, status int, result &char)
