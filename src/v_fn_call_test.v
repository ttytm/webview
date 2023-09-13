module webview

import time

struct Person {
	name string
	age  int
}

fn test_fn_call() {
	w := create(debug: true)

	mut fns_called := 0
	mut ref := &fns_called

	// We check if the V functions are called succesfully within 30 seconds.
	// Otherwise the window stays open and the test can run infinitely.
	spawn fn [w, ref] () {
		for i in 0 .. 30 {
			if *ref == 2 {
				assert true
				w.terminate()
				return
			}
			time.sleep(1 * time.second)
		}
		eprintln('Failed calling V functions.')
		assert false
	}()

	w.bind_ctx('v_fn', fn (e &Event, mut fns_called &int) {
		fns_called++
		assert e.string(0) == 'foo'
	}, fns_called)
	w.bind_ctx('v_fn_with_obj_arg', fn (e &Event, mut fns_called &int) {
		fns_called++
		p := e.decode[Person](0) or {
			eprintln(err)
			assert false
			return
		}
		println(p)
		assert p.name == 'john'
		assert p.age == 30
	}, fns_called)

	w.set_html('<html style="background: #1B2845; color: #eee">
<samp>${@FILE}</samp>
<script>
	const person = {
		name: "john",
		age: 30
	}
	setTimeout(async () => {
		await window.v_fn("foo");
	}, 500)
	setTimeout(async () => {
		await window.v_fn_with_obj_arg(JSON.stringify(person));
	}, 1000)
</script>
</html>')

	w.run()
}
