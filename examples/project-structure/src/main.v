import webview

struct App {
mut:
	settings Settings
}

struct Settings {
mut:
	toggle bool
}

fn main() {
	w := webview.create(debug: true)
	mut app := App{
		settings: Settings{true}
	}
	app.bind(w)
	w.set_title('V webview examples')
	w.set_size(800, 600, .@none)
	w.navigate('file://${@VMODROOT}/ui/index.html')
	w.set_icon('${@VMODROOT}/assets/icon.ico')!
	w.run()
	w.destroy()
}
