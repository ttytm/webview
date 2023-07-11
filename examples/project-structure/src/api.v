import json
import webview

fn (mut app App) bind() {
	// The first string arg names the functions for JS usage. E.g. use JS's `camelCase` convention if you prefer it.
	app.w.bind('connect', connect, &app)
	app.w.bind('toggle_setting', toggle, &app)
	app.w.bind('login', login, &app)
	app.w.bind('fetch_news', fetch_news, &app)
}

// The functions we bind do not have to be public. For semantic reasons we can do it anyway.

// Calls JS from V.
pub fn connect(event_id &char, args &char, app &App) {
	app.w.eval("console.log('Hello from V!');")
	app.w.eval('init(${json.encode(app.settings)});')
}

// Returns a value when it's called from JS.
pub fn toggle(event_id &char, args &char, mut app App) {
	app.settings.toggle = !app.settings.toggle
	dump(app.settings.toggle)
	app.w.result(event_id, json.encode(app.settings.toggle))
}

// Handles received arguments.
fn login(event_id &char, raw_args &char, mut app App) {
	// `raw_args` is a JSON array of all arguments passed to the JS function.
	mut resp := 'An error occured.'
	defer {
		app.w.result(event_id, json.encode(resp))
	}
	// Use the json module to handle decoding into the expected type.
	args := json.decode([]string, unsafe { raw_args.vstring() }) or { return }
	name := args[0] or { return }
	resp = 'Data received: Check your terminal.'
	println('Hello ${name}!')
}

// Spawns a thread and returns the functions result from it.
// This helps to avoid interferences with the UI when calling a function that can take some time to process
// (E.g., it allows to keep updating the content and animations running in the meantime).
// Let's refer to this as async example.
pub fn fetch_news(event_id &char, raw_args &char, app &App) {
	// With GC enabled:
	// Deref the event_id to keep it available when executing `webview.result` from the spawned thread.
	// Otherwise it gets obscured during garbage collection and using it in a `webview.result` won't
	// return data to the calling JS function.
	spawn app.fetch_news(*event_id)
}
