import webview { Event, Webview }

// Bind V callbacks to appear as global javascript functions.
fn (mut app App) bind(w &Webview) {
	// The first string arg names the functions for JS usage. E.g. use JS's `camelCase` convention if you prefer it.
	w.bind('get_settings', app.get_settings)
	w.bind_ctx('toggle_setting', toggle, app) // Alternatively use the ctx ptr to pass a struct.
	w.bind('login', login)
	w.bind('fetch_news', fetch_news)
}

// Returns a value when it's called from JS.
// This examples uses an `App` method, leaving the data ptr available for other potential uses.
fn (app App) get_settings(_ &Event) Settings {
	return app.settings
}

// Returns a value when it's called from JS.
// This examples uses the context argument to receive the app struct.
fn toggle(_ &Event, mut app App) bool {
	app.settings.toggle = !app.settings.toggle
	dump(app.settings.toggle)
	return app.settings.toggle
}

// Handles received arguments.
fn login(e &Event) string {
	name := e.string(0)
	println('Hello ${name}!')
	return 'Data received: Check your terminal.'
}

// Performs a longer taking task.
fn fetch_news(_ &Event) Article {
	// `fetch_news_()` is in the `news.v` file
	return fetch_news_()
}
