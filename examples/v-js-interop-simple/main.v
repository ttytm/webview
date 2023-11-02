import webview

const doc = '<!DOCTYPE html>
<html lang="en">
	<head>
		<style>
			body {
				background: linear-gradient(to right, #274060, #1b2845);
				color: GhostWhite;
				text-align: center;
				margin-top: 20px;
			}
			button {
				margin: 15px 0;
			}
		</style>
	</head>
	<body>
		<samp id="my-v-str"><i></i></samp>
		<br>
		<br>
		<div id="counter">
			<samp>Send data to V and receive data from V</samp>
			<br>
			<button id="count-btn">Double <span>2</span></button>
		</div>
		<script>
			// Functions that are declared in JS can also be called from your V program.
			function myJsFunction(myStrArg) {
				// NOTE: Building in debug mode enables developer tools for a winodw.
				// Also, console.log will additionally be printed to the terminal.
				// This feature currently works with Linux and Windows.
				console.log("Called myJsFunction:", myStrArg);
				document.querySelector("#my-v-str i").textContent = myStrArg;
			};
			(async () => {
				// Calls a V function that in turn calls the above JS function.
				window.interop();
			})();

			const countBtn = document.getElementById("count-btn");
			const count = countBtn.querySelector("span");
			countBtn.addEventListener("click", async () => {
				// Calls a V function that takes an argument and returns a Value.
				const res = await window.double(Number(count.textContent));
				count.textContent = res;
				console.log(res);
			});
		</script>
	</body>
</html>'

// Will be called from JS and calls JS.
fn interop(e &webview.Event) voidptr {
	my_str := 'This text was passed as an argument to a JS function that was called from V'
	e.eval('myJsFunction("${my_str}");')
	return webview.no_result
}

// Returns a value to JS.
fn double(e &webview.Event) int {
	my_num := e.get_arg[int](0) or {
		eprintln(err)
		return 0
	}
	dump(my_num)
	return my_num * 2
}

fn main() {
	w := webview.create()

	w.set_title('V webview Example')
	w.set_size(800, 600, .@none)
	w.set_html(doc)

	// Bind V callbacks to global javascript functions.
	w.bind('double', double)
	w.bind('interop', interop)

	// Calls JS.
	w.eval("console.log('Hello from V!');")

	w.run()
	w.destroy()
}
