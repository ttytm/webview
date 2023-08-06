import time
import json
import rand
import net.http

struct News {
	title string
	body  string
}

fn (app &App) fetch_news(event_id &char) {
	mut result := News{}
	defer {
		// Artificially delay the result to simulate a function that does some extended processing.
		time.sleep(time.second * 3)
		app.w.result(event_id, .value, json.encode(result))
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
