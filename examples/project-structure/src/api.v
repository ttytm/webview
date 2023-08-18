import json
import webview { copy_char }

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
// (We can use `_` to ignore unused parameters)
pub fn toggle(event_id &char, _ &char, mut app App) {
	app.settings.toggle = !app.settings.toggle
	dump(app.settings.toggle)
	app.w.result(event_id, .value, json.encode(app.settings.toggle))
}

// Handles received arguments.
pub fn login(event_id &char, raw_args &char, mut app App) {
	mut status := webview.Status.error
	mut resp := 'An error occurred'
	defer {
		app.w.result(event_id, status, json.encode(resp))
	}
	// All arguments passed to the JS function (here `raw_args`) are received as a JSON array.
	// Use the json module to handle decoding into the expected type.
	args := json.decode([]string, unsafe { raw_args.vstring() }) or { return }
	name := args[0] or { return }
	println('Hello ${name}!')
	resp = 'Data received: Check your terminal.'
	status = .value
}

// Spawns a thread and returns the functions result from it.
// This helps to avoid interferences with the UI when calling a function that can take some time to process
// (E.g., it allows to keep updating the content and animations running in the meantime).
// Let's refer to this as async example.
pub fn fetch_news(event_id &char, raw_args &char, app &App) {
	// Copying the event_id helps to keep it available when executing `webview.result` from the
	// spawned thread. Otherwise it can get obscured during garbage collection and cause errors.
	spawn app.fetch_news(copy_char(event_id))
}
