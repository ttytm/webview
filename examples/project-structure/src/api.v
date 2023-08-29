import webview { Event, Webview }
import time
import os

fn (mut app App) bind(w &Webview) {
	// The first string arg names the functions for JS usage. E.g. use JS's `camelCase` convention if you prefer it.
	w.bind('get_settings', app.get_settings)
	w.bind_ctx('toggle_setting', toggle, app) // Alternatively use the ctx ptr to pass a struct.
	w.bind('login', login)
	w.bind('knock_knock', knock_knock)
	w.bind('fetch_news', fetch_news)
}

// Returns a value when it's called from JS.
// This examples uses an `App` method, leaving the data ptr available for other potential uses.
fn (app App) get_settings(e &Event) {
	e.@return(app.settings)
}

// Returns a value when it's called from JS.
// This examples uses the context argument to receive the app struct.
fn toggle(e &Event, mut app App) {
	app.settings.toggle = !app.settings.toggle
	dump(app.settings.toggle)
	e.@return(app.settings.toggle)
}

// Handles received arguments.
fn login(e &Event) {
	mut status := webview.ReturnKind.error
	mut resp := 'An error occurred'
	defer {
		e.@return(resp, kind: status)
	}
	name := e.string(0)
	println('Hello ${name}!')
	resp = 'Data received: Check your terminal.'
	status = .value
}

// An operation that takes some time to process like this one
// will block the UI if it is not run from a thread.
// The `fetch_news` example below shows how to do async processing.
fn knock_knock(e &Event) {
	println('Follow the white rabbit 🐇')
	time.sleep(1 * time.second)
	for i in 0 .. 3 {
		print('\r${i + 1}...')
		os.flush()
		time.sleep(1 * time.second)
	}
	println('\rKnock, Knock, Neo.')
}

// Spawns a thread and returns a JS result from it.
// This helps to avoid interferences with the UI when calling a function that can take some time to process
// (E.g., it allows to keep updating the content and animations running in the meantime).
fn fetch_news(e &Event) {
	// Use `async()` if you want to return a JS result form another thread.
	spawn fetch_news_(e.async()) // `fetch_news_` function is in `news.v` file
}
