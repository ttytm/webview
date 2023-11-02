import webview { Event }
import rand
import net.http
import time
import json

struct App {
mut:
	settings Settings
}

struct Settings {
mut:
	toggle bool
}

struct Article {
	title string
	body  string
}

// Returns a value when it's called from JS.
// This examples uses an `App` method.
fn (app App) get_settings(_ &Event) Settings {
	return app.settings
}

// Returns a value when it's called from JS.
// This examples uses `bind_with_ctx` to add the App struct as context argument.
fn toggle(_ &Event, mut app App) bool {
	app.settings.toggle = !app.settings.toggle
	dump(app.settings.toggle)
	return app.settings.toggle
}

// Handles received arguments.
fn login(e &Event) string {
	name := e.get_arg[string](0) or {
		eprintln(err)
		return ''
	}
	println('Hello ${name}!')
	return 'Data received: Check your terminal.'
}

// Performs a longer taking task.
fn fetch_news(_ &Event) Article {
	mut result := Article{}
	resp := http.get('https://jsonplaceholder.typicode.com/posts') or {
		eprintln('Failed fetching news.')
		return result
	}

	// Further delay the return using the sleep function,
	// simulating a longer taking fetch or expensive computing.
	time.sleep(time.second * 2)

	news := json.decode([]Article, resp.body) or {
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

	w := webview.create()
	w.set_title('V webview examples')
	w.set_size(800, 600, .@none)
	w.set_icon('${@VMODROOT}/icon.ico')!

	// Bind V callbacks to global javascript functions.
	// The first string argument is the functions name in the JS frontend.
	// Use JS's `camelCase` convention or distinct identifiers if you prefer it.
	w.bind('get_settings', app.get_settings)
	w.bind_with_ctx('toggle_setting', toggle, &app) // Alternatively use the ctx ptr to pass a struct.
	w.bind('login', login)
	w.bind('fetch_news', fetch_news)

	w.navigate('file://${@VMODROOT}/index.html')

	w.run()
	w.destroy()
}
