import webview { EventId, JSArgs }
import rand
import net.http
import time
import json

struct App {
	w &webview.Webview
mut:
	settings struct {
	mut:
		toggle bool
	}
}

struct News {
	title string
	body  string
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

fn (app &App) fetch_news(event_id EventId) {
	mut result := News{}
	defer {
		// Artificially delay the result to simulate a function that does some extended processing.
		time.sleep(time.second * 3)
		app.w.@return(event_id, .value, result)
	}

	resp := http.get('https://jsonplaceholder.typicode.com/posts') or {
		eprintln('Failed fetching news.')
		return
	}

	news := json.decode([]News, resp.body) or {
		eprintln('Failed decoding news.')
		return
	}
	// Get a random article from the articles array.
	result = news[rand.int_in_range(0, news.len - 1) or { return }]
}

fn main() {
	mut app := App{
		w: webview.create(debug: true)
		settings: struct {true}
	}
	app.w.set_title('V webview examples')
	app.w.set_size(800, 600, .@none)

	// The first string argument is the functions name in the JS frontend.
	// Use JS's `camelCase` convention or distinct identifiers if you prefer it.
	app.w.bind('get_settings', app.get_settings, 0)
	app.w.bind('toggle_setting', toggle, &app)
	app.w.bind('login', login, &app)
	app.w.bind('fetch_news', fetch_news, &app)

	app.w.navigate('file://${@VMODROOT}/index.html')
	app.w.run()
	app.w.destroy()
}
