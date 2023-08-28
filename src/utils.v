module webview

import json

// copy_char copies a C style string. The functions main use case is passing an `event_id &char`
// to another thread. It helps to keep the event id available when executing `@retrun`
// from the spawned thread. Without copying the `event_id` might get obscured during garbage
// collection and returning data to a calling JS function becomes error prone.
fn copy_char(s &char) &char {
	return unsafe { &char(cstring_to_vstring(s).str) }
}

fn (e &Event) args_json[T]() ![]T {
	return json.decode([]T, unsafe { e.args.vstring() })!
}
