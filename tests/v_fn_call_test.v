import webview
import time

struct Person {
	name string
mut:
	age int
}

fn gen_html(test_name string, script string) string {
	return '<html style="background: #1B2845; color: #eee">
	<samp>${test_name}</samp>
	<script>${script}</script>
</html>'
}

fn test_timeout() {
	// We check if the V functions are called and windows closed successfully within 60 seconds.
	// Otherwise, windows can remain open and the test can run indefinitely.
	spawn fn () {
		time.sleep(60 * time.second)
		eprintln('Timeout trying to call V-functions from JS.')
		assert false
	}()
}

fn test_fn_call() {
	w := webview.create(debug: true)
	w.set_size(600, 400, .@none)
	w.bind('v_fn', fn [w] (e &webview.Event) voidptr {
		assert true
		w.terminate()
		return webview.no_result
	})
	script := '
	setTimeout(async () => {
		await window.v_fn();
	}, 500)'
	w.set_html(gen_html(@FN, script))
	w.run()
}

fn test_get_js_arg() {
	w := webview.create(debug: true)
	w.set_size(600, 400, .@none)
	w.bind[voidptr]('v_fn', fn [w] (e &webview.Event) {
		assert e.get_arg[string](0) or { '' } == 'foo'
		assert e.get_arg[int](1) or { 0 } == 123
		assert e.get_arg[bool](2) or { false } == true
		assert e.get_arg[Person](3) or { Person{} } == Person{'Bob', 30}
		assert e.get_arg[[]int](4) or { [0] } == [1, 2, 3]
		assert e.get_arg[[]int](-1) or { [0] } == [1, 2, 3]
		assert e.get_arg[Person](-2) or { Person{} } == Person{'Bob', 30}
		assert e.get_arg[bool](-3) or { false } == true
		assert e.get_arg[int](-4) or { 0 } == 123
		assert e.get_arg[string](-5) or { '' } == 'foo'
		w.terminate()
	})
	script := '
	setTimeout(async () => {
		const person = {
			name: "Bob",
			age: 30
		}
		await window.v_fn("foo", 123, true, JSON.stringify(person), JSON.stringify([1, 2, 3]));
	}, 500)'
	w.set_html(gen_html(@FN, script))
	w.run()
}

fn test_return_value_to_js() {
	w := webview.create(debug: true)
	w.set_size(600, 400, .@none)
	// Eventually possible with lambda expressions like below. Re-check as V development progresses.
	// w.bind('return_string', |_| 'bar')
	w.bind('v_return_string', fn (e &webview.Event) string {
		return 'bar'
	})
	w.bind('v_return_int', fn (e &webview.Event) int {
		return 123
	})
	w.bind('v_return_bool', fn (e &webview.Event) bool {
		return true
	})
	w.bind('v_return_struct', fn (e &webview.Event) Person {
		return Person{'Bob', 30}
	})
	w.bind('v_return_array', fn (e &webview.Event) []int {
		return [1, 2, 3]
	})
	// V function, called from JS, receiving the above return value as argument and asserts it's correctness.
	w.bind[voidptr]('assert_js_res_from_v', fn [w] (e &webview.Event) {
		assert e.get_arg[string](0) or { '' } == 'bar'
		assert e.get_arg[int](1) or { 0 } == 123
		assert e.get_arg[bool](2) or { false } == true
		assert e.get_arg[Person](3) or { Person{} } == Person{'Bob', 30}
		assert e.get_arg[[]int](4) or { [0] } == [1, 2, 3]
		w.terminate()
	})
	script := '
	setTimeout(async () => {
		const str = await window.v_return_string(),
			int = await window.v_return_int(),
			bool = await window.v_return_bool(),
			struct = await window.v_return_struct(),
			array = await window.v_return_array();
		await window.assert_js_res_from_v(str, int, bool, JSON.stringify(struct), JSON.stringify(array));
	}, 500)'
	w.set_html(gen_html(@FN, script))
	w.run()
}

// Simulate expensive computing using sleep function
fn expensive_computing(id int, duration int) int {
	println('Executing expensive computing task (${id})...')
	time.sleep(duration * time.millisecond)
	println('Finish task ${id} on ${duration} ms')
	return id * 2
}

fn test_return_value_from_threaded_task_to_js() {
	w := webview.create(debug: true)
	w.set_size(600, 400, .@none)
	// V function, called from JS, performs a threaded task and returns the value to JS
	w.bind('v_fn_with_threads', fn (_ &webview.Event) []int {
		mut threads := []thread int{}
		threads << spawn expensive_computing(1, 100)
		threads << spawn expensive_computing(2, 500)
		threads << spawn expensive_computing(3, 1000)
		// Join all tasks
		res := threads.wait()
		return res
	})
	// V function, called from JS, receiving the above thread result return value as argument and asserts it's correctness.
	w.bind[voidptr]('assert_v_to_js_thread_res', fn (e &webview.Event) {
		assert e.get_arg[[]int](0) or { [0] } == [2, 4, 6]
	})
	// If reached, it closes the Window and ends the test successfully.
	w.bind[voidptr]('exit', fn [w] (_ &webview.Event) {
		w.terminate()
	})
	script := '
	setTimeout(async () => {
		const res = await window.v_fn_with_threads();
		console.log("res:", res);
		await window.assert_v_to_js_thread_res(JSON.stringify(res));
		await window.exit();
	}, 1000) '
	w.set_html(gen_html(@FN, script))
	w.run()
}
