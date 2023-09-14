import webview { Event }
import rand
import net.http
import time
import json
import os

struct App {
mut:
	settings Settings
}

struct Settings {
mut:
	toggle bool
}

struct News {
	title string
	body  string
}

// Returns a value when it's called from JS.
// This examples uses an `App` method, leaving the data ptr available for other potential uses.
fn (app App) get_settings(e &Event) Settings {
	return app.settings
}

// Returns a value when it's called from JS.
// This examples uses the context argument to receive the app struct.
fn toggle(e &Event, mut app App) bool {
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

// An operation that takes some time to process like this one
// will block the UI if it is not run from a thread.
// The `fetch_news` example below shows how to do async processing.
fn knock_knock(e &Event) voidptr {
	println('Follow the white rabbit 🐇')
	time.sleep(1 * time.second)
	for i in 0 .. 3 {
		print('\r${i + 1}...')
		os.flush()
		time.sleep(1 * time.second)
	}
	println('\rKnock, Knock, Neo.')
	return webview.no_result
}

// Spawns a thread and returns a JS result from it.
// This helps to avoid interferences with the UI when calling a function that can take some time to process
// (E.g., it allows to keep updating the content and animations running in the meantime).
fn fetch_news(e &Event) News {
	mut result := News{}
	time.sleep(time.second * 3)
	resp := http.get('https://jsonplaceholder.typicode.com/posts') or {
		eprintln('Failed fetching news.')
		return result
	}
	news := json.decode([]News, resp.body) or {
		eprintln('Failed decoding news.')
		return result
	}
	// Get a random article from the articles array.
	result = news[rand.int_in_range(0, news.len - 1) or { return result }]
	return result
}

fn main() {
	mut app := App{
		settings: Settings{true}
	}

	w := webview.create(debug: true)
	w.set_title('V webview examples')
	w.set_size(800, 600, .@none)

	// The first string argument is the functions name in the JS frontend.
	// Use JS's `camelCase` convention or distinct identifiers if you prefer it.
	w.bind('get_settings', app.get_settings)
	w.bind_ctx('toggle_setting', toggle, &app) // Alternatively use the ctx ptr to pass a struct.
	w.bind('login', login)
	w.bind('knock_knock', knock_knock)
	w.bind('fetch_news', fetch_news)

	w.navigate('file://${@VMODROOT}/index.html')
	w.run()
	w.destroy()
}
