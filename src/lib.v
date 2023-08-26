/*
webview

This library provides a V binding for webview - a tiny library to build modern cross-platform GUI applications.
Doc comments for exported functions are adapted from the original headerfile webview.h.

License: MIT
Source: https://github.com/ttytm/webview
Source webview C library: https://github.com/webview/webview
*/

module webview

import json

pub type Webview = C.webview_t

pub type JSArgs = &char

pub type EventId = &char

pub enum Hint {
	// Width and height are default size
	@none = C.WEBVIEW_HINT_NONE
	// Window size can not be changed by a user
	fixed = C.WEBVIEW_HINT_FIXED
	// Width and height are minimum bounds
	min = C.WEBVIEW_HINT_MIN
	// Width and height are maximum bounds
	max = C.WEBVIEW_HINT_MAX
}

pub enum Status {
	value
	error
}

[params]
pub struct CreateOptions {
	debug  bool
	window voidptr
}

// create creates a new webview instance. If `debug` is `true` - developer tools
// will be enabled (if the platform supports them). The `window` parameter can be
// a pointer to the native window handle. If it's non-null - then child WebView
// is embedded into the given parent window. Otherwise a new window is created.
// Depending on the platform, a GtkWindow, NSWindow or HWND pointer can be
// passed here. Returns null on failure. Creation can fail for various reasons
// such as when required runtime dependencies are missing or when window creation
// fails.
pub fn create(opts CreateOptions) &Webview {
	return C.webview_create(int(opts.debug), opts.window)
}

// destroy destroys a webview and closes the native window.
pub fn (w &Webview) destroy() {
	C.webview_destroy(w)
}

// run runs the main loop until it's terminated. After this function exits - you
// must destroy the webview.
pub fn (w &Webview) run() {
	C.webview_run(w)
}

// terminate stops the main loop. It is safe to call this function from another
// other // background thread.
pub fn (w &Webview) terminate() {
	C.webview_terminate(w)
}

// dispatch posts a function to be executed on the main thread. You normally do
// not need to call this function, unless you want to tweak the native window.
pub fn (w &Webview) dispatch(func fn (w &Webview, arg voidptr), arg voidptr) {
	C.webview_dispatch(w, func, arg)
}

// get_window returns a native window handle pointer. When using a GTK backend
// the pointer is a GtkWindow pointer, when using a Cocoa backend the pointer is
// a NSWindow pointer, when using a Win32 backend the pointer is a HWND pointer.
pub fn (w &Webview) get_window() voidptr {
	return C.webview_get_window(w)
}

// set_title updates the title of the native window. Must be called from the UI thread.
pub fn (w &Webview) set_title(title string) {
	C.webview_set_title(w, &char(title.str))
}

// set_size updates the size of the native window. See WEBVIEW_HINT constants.
pub fn (w &Webview) set_size(width int, height int, hint Hint) {
	C.webview_set_size(w, width, height, int(hint))
}

// navigate navigates webview to the given URL. URL may be a properly encoded data URI.
// Example: w.navigate('https://github.com/webview/webview') {
// Example: w.navigate('data:text/html,%3Ch1%3EHello%3C%2Fh1%3E')
// Example: w.navigate('file://${@VMODROOT}/index.html')
pub fn (w &Webview) navigate(url string) {
	C.webview_navigate(w, &char(url.str))
}

// set_html set webview HTML directly.
pub fn (w &Webview) set_html(html string) {
	C.webview_set_html(w, &char(html.str))
}

// init injects JavaScript code at the initialization of the new page. Every time
// the webview will open a new page - this initialization code will be executed.
// It is guaranteed that code is executed before window.onload.
pub fn (w &Webview) init(code string) {
	C.webview_init(w, &char(code.str))
}

// eval evaluates arbitrary JavaScript code. Evaluation happens asynchronously, also
// the result of the expression is ignored. Use RPC bindings if you want to
// receive notifications about the results of the evaluation.
pub fn (w &Webview) eval(code string) {
	C.webview_eval(w, &char(code.str))
}

// bind binds a native C callback so that it will appear under the given name as a
// global JavaScript function. Internally it uses webview_init(). The callback
// receives a sequential request id, a request string and a user-provided
// argument pointer. The request string is a JSON array of all the arguments
// passed to the JavaScript function.
pub fn (w &Webview) bind(name string, func fn (event_id EventId, args JSArgs, data voidptr), data voidptr) {
	C.webview_bind(w, &char(name.str), func, data)
}

// unbind removes a native C callback that was previously set by webview_bind.
pub fn (w &Webview) unbind(name string) {
	C.webview_unbind(w, &char(name.str))
}

// @return allows to return a value from the native binding. A request id pointer must
// be provided to allow the internal RPC engine to match the request and response.
// If the status is zero - the result is expected to be a valid JSON value.
// If the status is not zero - the result is an error JSON object.
pub fn (w &Webview) @return[T](event_id EventId, status Status, result T) {
	C.webview_return(w, event_id, int(status), &char(json.encode(result).str))
}

// copy should be used if you want to return a JS result form another thread.
// Without copying the event id can get corrupted during garbage collection and using
// it in a `webview.result` wouldn't return data to the calling JS function.
// Example:
// ```v
// fn fetch_data(event_id EventId, args JSArgs, app &App) {
// 	spawn app.fetch_data(event_id.copy())
// }
// ```
pub fn (e EventId) copy() EventId {
	return EventId(unsafe { &char(cstring_to_vstring(&char(e)).str) })
}

fn (args JSArgs) json[T]() ![]T {
	return json.decode([]T, unsafe { (&char(args)).vstring() }) or {
		return error('Failed decoding arguments. ${err}')
	}
}

// string decodes and returns the argument with the given index as string.
pub fn (args JSArgs) string(idx usize) string {
	return args.json[string]() or { return '' }[int(idx)] or { '' }
}

// int decodes and returns the argument with the given index as integer.
pub fn (args JSArgs) int(idx usize) int {
	return args.json[int]() or { return 0 }[int(idx)] or { return 0 }
}

// bool decodes and returns the argument with the given index as boolean.
pub fn (args JSArgs) bool(idx usize) bool {
	return args.json[bool]() or { return false }[int(idx)] or { return false }
}

// string_opt decodes and returns the argument with the given index as string option.
pub fn (args JSArgs) string_opt(idx usize) ?string {
	return args.json[string]() or { return none }[int(idx)] or { return none }
}

// int_opt decodes and returns the argument with the given index as integer option.
pub fn (args JSArgs) int_opt(idx usize) ?int {
	return args.json[int]() or { return none }[int(idx)] or { return none }
}

// bool_opt decodes and return the argument with the given index as boolean option.
pub fn (args JSArgs) bool_opt(idx int) ?bool {
	return args.json[bool]() or { return none }[int(idx)] or { return none }
}

// decode decodes and returns `JSArgs` into a V data type.
pub fn (args JSArgs) decode[T]() T {
	return json.decode(T, unsafe { (&char(args)).vstring() }) or {
		return error('Failed decoding arguments. ${err}')
	}
}
