module webview

import json

// copy_char copies a C style string. The functions main use case is passing an `event_id &char`
// to another thread. It helps to keep the event id available when executing `@return`
// from the spawned thread. Without copying the `event_id` might get obscured during garbage
// collection and returning data to a calling JS function becomes error prone.
fn copy_char(s &char) &char {
	return unsafe { &char(cstring_to_vstring(s).str) }
}

// @return allows to return a value from the native binding. A request id pointer must
// be provided to allow the internal RPC engine to match the request and response.
// If the status is zero - the result is expected to be a valid JSON value.
// If the status is not zero - the result is an error JSON object.
fn (e &Event) @return[T](result T, return_params ReturnParams) {
	$if result is voidptr {
		C.webview_return(e.instance, e.event_id, 0, &char(''.str))
	} $else {
		C.webview_return(e.instance, e.event_id, 0, &char(json.encode(result).str))
	}
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
fn (e &Event) async() &Event {
	return &Event{e.instance, copy_char(e.event_id), copy_char(e.args)}
}

fn (e &Event) args_json[T]() ![]T {
	return json.decode([]T, unsafe { e.args.vstring() })!
}
