import webview { EventId, JSArgs }

fn (mut app App) bind() {
	// The first string arg names the functions for JS usage. E.g. use JS's `camelCase` convention if you prefer it.
	app.w.bind('get_settings', app.get_settings, 0)
	app.w.bind('toggle_setting', toggle, &app)
	app.w.bind('login', login, &app)
	app.w.bind('fetch_news', fetch_news, &app)
}

// Returns a value when it's called from JS.
// This examples uses an `App` method, leaving the data ptr available for other potential uses.
fn (app App) get_settings(event_id EventId, _ JSArgs, data voidptr) {
	app.w.@return(event_id, .value, app.settings)
}

// Returns a value when it's called from JS.
// This examples uses the data ptr to receive the app object.
fn toggle(event_id EventId, _ JSArgs, mut app App) {
	app.settings.toggle = !app.settings.toggle
	dump(app.settings.toggle)
	app.w.@return(event_id, .value, app.settings.toggle)
}

// Handles received arguments.
fn login(event_id EventId, args JSArgs, app &App) {
	mut status := webview.Status.error
	mut resp := 'An error occurred'
	defer {
		app.w.@return(event_id, status, resp)
	}
	name := args.string(0)
	println('Hello ${name}!')
	resp = 'Data received: Check your terminal.'
	status = .value
}

// Spawns a thread and returns the functions result from it.
// This helps to avoid interferences with the UI when calling a function that can take some time to process
// (E.g., it allows to keep updating the content and animations running in the meantime).
// Let's refer to this as async example.
fn fetch_news(event_id EventId, _ JSArgs, app &App) {
	// Use copy if you want to return a JS result form another thread.
	spawn app.fetch_news(event_id.copy())
}
