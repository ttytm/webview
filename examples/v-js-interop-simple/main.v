import webview { EventId, JSArgs }

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
		<script>
			// Functions that are declared in JS can also be called from your V program.
			function myJsFunction(myArg) {
				console.log("Called myJsFunction:", myArg);
			};
			// Calls a V function that uses above JS
			window.interop();

			// Calls a V function that returns a Value
			(async () => {
				const num = await window.double(2);
				console.log(num);
			})();
		</script>
	</body>
</html>'

// Will be called from JS and calls JS.
fn interop(_ EventId, _ JSArgs, w &webview.Webview) {
	w.eval('myJsFunction("My JS arg sent from V");')
}

// Returns a value to JS
fn double(event_id EventId, args JSArgs, w &webview.Webview) {
	w.@return(event_id, .value, args.int(0) * 2)
}

fn main() {
	w := webview.create(debug: true)

	w.set_title('V webview Example')
	w.bind('double', double, w)
	w.bind('interop', interop, w)
	w.set_html(doc)

	// Calls JS.
	w.eval("console.log('Hello from V!');")

	w.run()
	w.destroy()
}
