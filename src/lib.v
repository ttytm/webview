/*
webview

This library provides a V binding for webview - a tiny library to build modern cross-platform GUI applications.
Doc comments for exported functions are adapted from the original headerfile webview.h.

License: MIT
Source: https://github.com/ttytm/webview
Source webview C library: https://github.com/webview/webview
*/

module webview

import icon
import serve
import os

@[heap]
pub struct Webview {
mut:
	w    C.webview_t // Pointer to a webview instance.
	proc &os.Process
}

// An Event which a V function receives that is called by javascript.
pub struct Event {
pub:
	instance C.webview_t // Pointer to the events webview instance.
	event_id &char
	args     &char
}

@[params]
pub struct CreateOptions {
pub:
	debug  ?bool
	window voidptr
}

@[params]
pub struct ServeStaticOptions {
pub:
	port u16 = 4321
}

@[params]
pub struct ServeDevOptions {
pub:
	pkg_manager serve.PackageManager // .node || .yarn || .pnpm
	script      string = 'dev' // name of the script(specified in package.json) that runs the dev instance.
}

// A Hint that is passed to the Webview 'set_size' method to determine the window sizing behavior.
pub enum Hint {
	// Width and height are default size.
	@none = C.WEBVIEW_HINT_NONE
	// Window size can not be changed by a user.
	fixed = C.WEBVIEW_HINT_FIXED
	// Width and height are minimum bounds.
	min = C.WEBVIEW_HINT_MIN
	// Width and height are maximum bounds.
	max = C.WEBVIEW_HINT_MAX
}

pub const no_result = unsafe { nil }

const debug = $if webview_debug ? { true } $else { false }

// create creates a new webview instance. Optionally, a `debug` and `window` parameter can be passed.
// If `debug` is `true` - developer tools will be enabled (if the platform supports them).
// The `window` parameter can be a pointer to the native window handle. If it's non-null, then the
// WebView is embedded into the given parent window. Otherwise a new window is created.
// Depending on the platform, a GtkWindow, NSWindow or HWND pointer can be passed here.
// Returns null on failure. Creation can fail for various reasons such as when required runtime
// dependencies are missing or when window creation fails.
pub fn create(opts CreateOptions) &Webview {
	// The window `debug` param takes precedence. If the window is reated with `debug` set to false,
	// debugging will not be enabled for the window even the app is build with `-d webui_debug`.
	dbg := if opt := opts.debug {
		opt
	} else {
		debug
	}
	return &Webview{C.webview_create(int(dbg), opts.window), unsafe { nil }}
}

// destroy destroys a webview and closes the native window.
pub fn (w Webview) destroy() {
	C.webview_destroy(w.w)
	if !isnil(w.proc) {
		mut p := &os.Process{}
		p = unsafe { w.proc }
		p.signal_pgkill()
	}
}

// run runs the main loop until it's terminated. After this function exits - you
// must destroy the webview.
pub fn (w &Webview) run() {
	C.webview_run(w.w)
}

// terminate stops the main loop. It is safe to call this function from another
// other background thread.
pub fn (w &Webview) terminate() {
	C.webview_terminate(w.w)
}

// dispatch posts a function to be executed on the main thread. You normally do
// not need to call this function, unless you want to tweak the native window.
pub fn (w &Webview) dispatch(func fn ()) {
	C.webview_dispatch(w.w, fn [func] (w C.webview_t, ctx voidptr) {
		func()
	}, 0)
}

// dispatch_ctx posts a function to be executed on the main thread. You normally do
// not need to call this function, unless you want to tweak the native window.
pub fn (w &Webview) dispatch_ctx(func fn (ctx voidptr), ctx voidptr) {
	C.webview_dispatch(w.w, fn [func] (w C.webview_t, ctx voidptr) {
		func(ctx)
	}, ctx)
}

// get_window returns a native window handle pointer. When using a GTK backend
// the pointer is a GtkWindow pointer, when using a Cocoa backend the pointer is
// a NSWindow pointer, when using a Win32 backend the pointer is a HWND pointer.
pub fn (w &Webview) get_window() voidptr {
	return C.webview_get_window(w.w)
}

// set_icon updates the icon of the native window. It supports Windows HWND windows and Linux GTK
// windows under X11 - under Wayland, window application mapping is based on the desktop file entry name.
// TODO: add macOS support
pub fn (w &Webview) set_icon(icon_file_path string) ! {
	return icon.set_icon(w.get_window(), icon_file_path)
}

// set_title updates the title of the native window. Must be called from the UI thread.
pub fn (w &Webview) set_title(title string) {
	C.webview_set_title(w.w, &char(title.str))
}

// set_size updates the size of the native window. See WEBVIEW_HINT constants.
pub fn (w &Webview) set_size(width int, height int, hint Hint) {
	C.webview_set_size(w.w, width, height, int(hint))
}

// navigate navigates webview to the given URL. URL may be a properly encoded data URI.
// Example: w.navigate('https://github.com/webview/webview')
// Example: w.navigate('data:text/html,%3Ch1%3EHello%3C%2Fh1%3E')
// Example: w.navigate('file://${@VMODROOT}/index.html')
pub fn (w &Webview) navigate(url string) {
	C.webview_navigate(w.w, &char(url.str))
}

// set_html set webview HTML directly.
pub fn (w &Webview) set_html(html string) {
	C.webview_set_html(w.w, &char(html.str))
}

// serve_dev uses the given package manger to run the given script name and
// navigates to the localhost address on which the application is served.
// Example:
// ```
// // Runs `npm run dev` in the `ui` directory.
// w.serve_dev('ui')!
// // Runs `yarn run start` in the `ui` directory (specifying an absolute path).
// w.serve_dev(os.join_path(@VMODROOT, 'ui'), pkg_manager: 'yarn', script: 'start')!
// ```
pub fn (mut w Webview) serve_dev(ui_path string, opts ServeDevOptions) ! {
	if !isnil(w.proc) {
		return error('a dev process is already running.
	executable: `${w.proc.filename}`
	arguments: `${w.proc.args.join(' ')}`
	directory: `${w.proc.work_folder}`')
	}
	mut proc, port := serve.serve_dev(ui_path, opts.pkg_manager, opts.script)!
	w.proc = proc
	w.navigate('http://localhost:${port}')
}

// serve_static serves a UI that has been built into a static site on localhost and
// navigates to it address. Optionally, a port can be specified to serve the site.
// By default, the next free port from `4321` is used.
pub fn (w &Webview) serve_static(ui_build_path string, opts ServeStaticOptions) ! {
	port := serve.serve_static(ui_build_path, opts.port)!
	w.navigate('http://localhost:${port}')
}

// init injects JavaScript code at the initialization of the new page. Every time
// the webview will open a new page - this initialization code will be executed.
// It is guaranteed that code is executed before window.onload.
pub fn (w &Webview) init(code string) {
	C.webview_init(w.w, &char(code.str))
}

// eval evaluates arbitrary JavaScript code. Evaluation happens asynchronously, also
// the result of the expression is ignored. Use RPC bindings if you want to
// receive notifications about the results of the evaluation.
pub fn (w &Webview) eval(code string) {
	C.webview_eval(w.w, &char(code.str))
}

// bind binds a V callback to a global JavaScript function that will appear under the given name.
// The callback receives an `&Event` argument. Internally it uses webview_init().
pub fn (w &Webview) bind[T](name string, func fn (&Event) T) {
	C.webview_bind(w.w, &char(name.str), fn [w, func] [T](event_id &char, args &char, ctx voidptr) {
		e := unsafe { &Event{w.w, event_id, args} }.async()
		spawn fn [func, e] [T]() {
			result := func(e)
			e.@return(result, .value)
		}()
	}, 0)
}

// bind_opt binds a V callback with a result return type to a global JavaScript function that will
// appear under the given name. The callback receives an `&Event` argument. The callback can return an
// error to the calling JavaScript function. Internally it uses webview_init().
pub fn (w &Webview) bind_opt[T](name string, func fn (&Event) !T) {
	C.webview_bind(w.w, &char(name.str), fn [w, func] [T](event_id &char, args &char, ctx voidptr) {
		e := unsafe { &Event{w.w, event_id, args} }.async()
		spawn fn [func, e] [T]() {
			if result := func(e) {
				e.@return(result, .value)
			} else {
				e.@return(err.str(), .error)
			}
		}()
	}, 0)
}

// bind_with_ctx binds a V callback to a global JavaScript function that will appear under the given name.
// The callback receives an `&Event` and a user-provided ctx pointer argument.
pub fn (w &Webview) bind_with_ctx[T](name string, func fn (e &Event, ctx voidptr) T, ctx voidptr) {
	C.webview_bind(w.w, &char(name.str), fn [w, func] [T](event_id &char, args &char, ctx voidptr) {
		e := unsafe { &Event{w.w, event_id, args} }.async()
		spawn fn [func, e, ctx] [T]() {
			result := func(e, ctx)
			e.@return(result, .value)
		}()
	}, ctx)
}

// bind_opt_with_ctx binds a V callback with a result return type to a global JavaScript function that will
// appear under the given name. The callback receives an `&Event` and a user-provided ctx pointer argument.
// The callback can return an error to the calling JavaScript function. Internally it uses webview_init().
pub fn (w &Webview) bind_opt_with_ctx[T](name string, func fn (e &Event, ctx voidptr) T, ctx voidptr) {
	C.webview_bind(w.w, &char(name.str), fn [w, func] [T](event_id &char, args &char, ctx voidptr) {
		e := unsafe { &Event{w.w, event_id, args} }
		spawn fn [func, ctx] [T](e &Event) {
			if result := func(e, ctx) {
				e.@return(result, .value)
			} else {
				e.@return(err, .error)
			}
		}(e.async())
	}, ctx)
}

// unbind removes a native C callback that was previously set by webview_bind.
pub fn (w &Webview) unbind(name string) {
	C.webview_unbind(w.w, &char(name.str))
}

// dispatch posts a function to be executed on the main thread. You normally do
// not need to call this function, unless you want to tweak the native window.
// This is a shorthand for `e.instance.dispatch()`.
pub fn (e &Event) dispatch(func fn ()) {
	C.webview_dispatch(e.instance, fn [func] (w C.webview_t, ctx voidptr) {
		func()
	}, 0)
}

// dispatch_ctx posts a function to be executed on the main thread. You normally do
// not need to call this function, unless you want to tweak the native window.
// This is a shorthand for `e.instance.dispatch_ctx()`.
pub fn (e &Event) dispatch_ctx(func fn (ctx voidptr), ctx voidptr) {
	C.webview_dispatch(e.instance, fn [func] (w C.webview_t, ctx voidptr) {
		func(ctx)
	}, ctx)
}

// eval evaluates arbitrary JavaScript code. Evaluation happens asynchronously, also
// the result of the expression is ignored. Use RPC bindings if you want to receive
// notifications about the results of the evaluation.
// This is a shorthand for `e.instance.eval()`.
pub fn (e &Event) eval(code string) {
	C.webview_eval(e.instance, &char(code.str))
}

// get_arg parses the JavaScript argument into a V data type.
pub fn (e &Event) get_arg[T](idx int) !T {
	$if T is int {
		return e.get_args_json[T](idx)!
	} $else $if T is string {
		return e.get_args_json[T](idx)!
	} $else $if T is bool {
		return e.get_args_json[T](idx)!
	} $else {
		return e.get_complex_args_json[T](idx)!
	}
}

// open opens a path or URL with the system's default application.
// Use a bind function to make it available in JavaScript.
// Example: w.bind_opt[voidptr]('open', ui.open)
pub fn open(e &Event) ! {
	url := e.get_arg[string](0)!
	os.open_uri(url)!
}
