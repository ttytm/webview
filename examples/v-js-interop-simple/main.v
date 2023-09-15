import webview

const doc = '<!DOCTYPE html>
<html lang="en">
	<head>
		<style>
			body {
				background-color: #1c2128;
				color: AliceBlue;
			}
		</style>
	</head>
	<body>
		<samp>Check your terminal...</samp>
		<script>
			// Functions that are declared in JS can also be called from your V program.
			function myJsFunction(myArg) {
				console.log("Called myJsFunction:", myArg);
			};
			// Calls a V function that in turn calls the above JS function.
			window.interop();

			// Calls a V function that returns a Value.
			(async () => {
				num = await window.double(2);
				console.log(num);
			})();
		</script>
	</body>
</html>'

// Will be called from JS and calls JS.
fn interop(e &webview.Event) voidptr {
	my_js_arg := 'My JS arg sent from V'
	e.eval('myJsFunction("${my_js_arg}");')
	return webview.no_result
}

// Returns a value to JS.
fn double(e &webview.Event) int {
	return e.int(0) * 2
}

fn main() {
	w := webview.create(debug: true)

	w.set_title('V webview Example')
	w.bind('double', double)
	w.bind('interop', interop)
	w.set_html(doc)

	// Calls JS.
	w.eval("console.log('Hello from V!');")

	w.run()
	w.destroy()
}
