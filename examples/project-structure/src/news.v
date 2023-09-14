import time
import json
import rand
import net.http

struct Article {
	title string
	body  string
}

fn fetch_news_() Article {
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
