import webview

struct App {
mut:
	settings struct {
	mut:
		toggle bool
	}
}

fn main() {
	w := webview.create(debug: true)
	mut app := App{
		settings: struct {true}
	}
	app.bind(w)
	w.set_title('V webview examples')
	w.set_size(800, 600, .@none)
	w.navigate('file://${@VMODROOT}/ui/index.html')
	w.run()
	w.destroy()
}
