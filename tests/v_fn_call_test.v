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
	// We check if the V functions are called and windows closed successfully within 30 seconds.
	// Otherwise, windows can remain open and the test can run indefinitely.
	spawn fn () {
		time.sleep(60 * time.second)
		eprintln('Timeout trying to call V-functions from JS.')
		assert false
	}()
}

fn test_fn_call() {
	w := webview.create(debug: true)
	// V function, called from JS, receiving a string argument.
	w.bind('v_fn', fn [w] (e &webview.Event) voidptr {
		assert true
		w.terminate()
		return webview.no_result
	})
	script := '
	setTimeout(async () => {
		await window.v_fn("foo");
	}, 500)'
	w.set_html(gen_html(@FN, script))
	w.run()
}

fn test_fn_call_with_js_return() {
	w := webview.create(debug: true)
	// V function, called from JS, receiving a string argument.
	w.bind('v_fn', fn (e &webview.Event) string {
		assert e.string(0) == 'foo'
		return 'bar'
	})
	// V function, called from JS, receiving the above return value as argument and asserts it's correctness.
	w.bind[voidptr]('assert_js_res_from_v', fn [w] (e &webview.Event) {
		assert e.string(0) == 'bar'
		w.terminate()
	})
	script := '
	setTimeout(async () => {
		const res = await window.v_fn("foo");
		await window.assert_js_res_from_v(res);
	}, 500)'
	w.set_html(gen_html(@FN, script))
	w.run()
}

fn test_fn_call_with_obj_arg() {
	w := webview.create(debug: true)
	// V function, called from the JS, receiving an Obj argument as JSON string.
	w.bind('v_fn_with_obj_arg', fn (e &webview.Event) Person {
		mut p := e.decode[Person](0) or {
			eprintln(err)
			assert false
			exit(0)
		}
		println(p)
		assert p.name == 'Bob'
		assert p.age == 30
		// Let's celebrate Bob's birthday.
		p.age += 1
		return p
	})
	// V function, called from JS, receiving the above return value as argument and asserts it's correctness.
	w.bind[voidptr]('assert_v_to_js_res', fn [w] (e &webview.Event) {
		p := e.decode[Person](0) or {
			eprintln(err)
			assert false
			exit(0)
		}
		println(p)
		assert p.name == 'Bob'
		assert p.age == 31
		w.terminate()
	})
	script := '
	const person = {
		name: "Bob",
		age: 30
	}
	setTimeout(async () => {
		const res = await window.v_fn_with_obj_arg(JSON.stringify(person));
		console.log("res:", res, "| res string:", JSON.stringify(res));
		await window.assert_v_to_js_res(JSON.stringify(res));
	}, 1000)'
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

fn test_fn_call_with_js_return_from_threaded_task() {
	w := webview.create(debug: true)
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
		res := e.decode[[]int](0) or {
			eprintln(err)
			assert false
			exit(0)
		}
		assert res == [2, 4, 6]
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
