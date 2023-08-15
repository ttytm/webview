module bindings

#flag linux -DWEBVIEW_GTK -lstdc++
#flag darwin -DWEBVIEW_COCOA -framework WebKit -stdlib=libc++ -lstdc++
#flag windows -DWEBVIEW_EDGE -static -ladvapi32 -lole32 -lshell32 -lshlwapi -luser32 -lversion -lstdc++

#flag @VMODROOT/src/bindings/webview.o
#include "@VMODROOT/src/bindings/webview.h"

$if linux {
	#pkgconfig gtk+-3.0
	#pkgconfig webkit2gtk-4.0
}

// Internal helper to silence the parser's warning about an unused binding module
// despite its C bindings being used.
pub const used = true

pub struct C.webview_t {}

fn C.webview_create(debug int, window voidptr) &C.webview_t

fn C.webview_destroy(w &C.webview_t)

fn C.webview_run(w &C.webview_t)

fn C.webview_terminate(w &C.webview_t)

fn C.webview_dispatch(w &C.webview_t, func fn (&C.webview_t, voidptr), arg voidptr)

fn C.webview_get_window(w &C.webview_t) voidptr

fn C.webview_set_title(w &C.webview_t, title &char)

fn C.webview_set_size(w &C.webview_t, width int, height int, hints int)

fn C.webview_navigate(w &C.webview_t, url &char)

fn C.webview_set_html(w &C.webview_t, html &char)

fn C.webview_init(w &C.webview_t, code &char)

fn C.webview_eval(w &C.webview_t, code &char)

fn C.webview_bind(w &C.webview_t, func_name &char, func fn (&char, &char, voidptr), arg voidptr)

fn C.webview_unbind(w &C.webview_t, func_name &char)

fn C.webview_return(w &C.webview_t, seq &char, status int, result &char)
