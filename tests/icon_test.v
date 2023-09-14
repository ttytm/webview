import webview

fn test_set_icon() {
	mut w := webview.create(debug: false)
	w.set_size(600, 400, .@none)
	w.set_title('testing icon change')
	w.set_html('<html style="background: #1B2845; color: #eee">
<samp>${@FILE}</samp>
<h2>Testing set_icon</h2>
</html>')
	w.set_icon('${@VMODROOT}/tests/icon.ico') or { panic(err) }
	w.run()

	w.destroy()
}
