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

pub struct Event {
pub:
	instance &Webview // Pointer to the webview instance
	event_id &char
	args     &char
}

[params]
pub struct CreateOptions {
	debug  bool
	window voidptr
}

[params]
pub struct ReturnParams {
	kind ReturnKind
}

pub enum ReturnKind {
	value
	error
}

// Window size hints
pub enum Hint {
	// Width and height are default size
	@none = C.WEBVIEW_HINT_NONE
	// Window size can not be changed by a user
	fixed = C.WEBVIEW_HINT_FIXED
	// Width and height are minimum bounds
	min   = C.WEBVIEW_HINT_MIN
	// Width and height are maximum bounds
	max   = C.WEBVIEW_HINT_MAX
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
// other background thread.
pub fn (w &Webview) terminate() {
	C.webview_terminate(w)
}

// dispatch posts a function to be executed on the main thread. You normally do
// not need to call this function, unless you want to tweak the native window.
pub fn (w &Webview) dispatch(func fn ()) {
	C.webview_dispatch(w, fn [func] (w &Webview, ctx voidptr) {
		func()
	}, 0)
}

// dispatch_ctx posts a function to be executed on the main thread. You normally do
// not need to call this function, unless you want to tweak the native window.
pub fn (w &Webview) dispatch_ctx(func fn (ctx voidptr), ctx voidptr) {
	C.webview_dispatch(w, fn [func] (w &Webview, ctx voidptr) {
		func(ctx)
	}, ctx)
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

// bind binds a callback so that it will appear under the given name as a
// global JavaScript function. Internally it uses webview_init().
// The callback receives an `&Event` pointer.
pub fn (w &Webview) bind(name string, func fn (&Event)) {
	C.webview_bind(w, &char(name.str), fn [w, func] (event_id &char, args &char, ctx voidptr) {
		func(unsafe { &Event{w, event_id, args} })
	}, 0)
}

// bind_ctx binds a callback so that it will appear under the given name as a
// global JavaScript function. Internally it uses webview_init().
// The callback receives an `7Event` pointer and a user-provided ctx pointer.
pub fn (w &Webview) bind_ctx(name string, func fn (e &Event, ctx voidptr), ctx voidptr) {
	C.webview_bind(w, &char(name.str), fn [w, func] (event_id &char, args &char, ctx voidptr) {
		func(unsafe { &Event{w, event_id, args} }, ctx)
	}, ctx)
}

// unbind removes a native C callback that was previously set by webview_bind.
pub fn (w &Webview) unbind(name string) {
	C.webview_unbind(w, &char(name.str))
}

// @return allows to return a value from the native binding. A request id pointer must
// be provided to allow the internal RPC engine to match the request and response.
// If the status is zero - the result is expected to be a valid JSON value.
// If the status is not zero - the result is an error JSON object.
pub fn (e &Event) @return[T](result T, return_params ReturnParams) {
	C.webview_return(e.instance, e.event_id, int(return_params.kind), &char(json.encode(result).str))
}

// async should be used if you want to return a JS result form another thread.
// Without calling `async()`, the events id can get corrupted during garbage collection
// and using it in a `@return` would not return data to the calling JS function.
// Example:
// ```v
// fn my_async_func(event &Event) {
// 	spawn fetch_data(event.async())
// }
// ```
pub fn (e &Event) async() &Event {
	return &Event{e.instance, copy_char(e.event_id), e.args}
}

// dispatch posts a function to be executed on the main thread. You normally do
// not need to call this function, unless you want to tweak the native window.
// This is a shorthand for `e.instance.dispatch()`.
pub fn (e &Event) dispatch(func fn ()) {
	C.webview_dispatch(e.instance, fn [func] (w &Webview, ctx voidptr) {
		func()
	}, 0)
}

// dispatch_ctx posts a function to be executed on the main thread. You normally do
// not need to call this function, unless you want to tweak the native window.
// This is a shorthand for `e.instance.dispatch_ctx()`.
pub fn (e &Event) dispatch_ctx(func fn (ctx voidptr), ctx voidptr) {
	C.webview_dispatch(e.instance, fn [func] (w &Webview, ctx voidptr) {
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

// string decodes and returns the event argument with the given index as string.
pub fn (e &Event) string(idx usize) string {
	return e.args_json[string]() or { return '' }[int(idx)] or { '' }
}

// int decodes and returns the argument with the given index as integer.
pub fn (e &Event) int(idx usize) int {
	return e.args_json[int]() or { return 0 }[int(idx)] or { return 0 }
}

// bool decodes and returns the argument with the given index as boolean.
pub fn (e &Event) bool(idx usize) bool {
	return e.args_json[bool]() or { return false }[int(idx)] or { return false }
}

// string_opt decodes and returns the argument with the given index as string option.
pub fn (e &Event) string_opt(idx usize) ?string {
	return e.args_json[string]() or { return none }[int(idx)] or { return none }
}

// int_opt decodes and returns the argument with the given index as integer option.
pub fn (e &Event) int_opt(idx usize) ?int {
	return e.args_json[int]() or { return none }[int(idx)] or { return none }
}

// bool_opt decodes and return the argument with the given index as boolean option.
pub fn (e &Event) bool_opt(idx usize) ?bool {
	return e.args_json[bool]() or { return none }[int(idx)] or { return none }
}

// decode decodes and returns the argument with the given index into a V data type.
pub fn (e &Event) decode[T](idx usize) !T {
	return json.decode(T, e.string(idx)) or { return error('Failed decoding arguments. ${err}') }
}
