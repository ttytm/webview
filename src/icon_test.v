module webview

fn test_set_icon() {
	mut w := create(debug: false)
	w.set_title('webview')
	w.set_size(600, 400, .@none)
	w.set_html('<html style="background: #1B2845; color: #eee">
<samp>${@FILE}</samp>
<h2>Testing set_icon</h2>
</html>')
	w.set_window_icon('${@VMODROOT}/assets/icon_2.ico')
	w.run()

	w.destroy()
}
