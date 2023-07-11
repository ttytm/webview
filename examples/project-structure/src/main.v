import webview

struct App {
	w &webview.Webview
mut:
	settings struct {
	mut:
		toggle bool
	}
}

fn main() {
	mut app := App{
		w: webview.create(debug: true)
		settings: struct {true}
	}
	app.bind()
	app.w.set_size(800, 600, .@none)
	app.w.navigate('file://${@VMODROOT}/ui/index.html')
	app.w.run()
	app.w.destroy()
}
