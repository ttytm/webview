import os
import ttytm.webview as ui

fn increment(e &ui.Event) !int {
	return e.get_arg[int](0)! + 1
}

fn main() {
	// Create a Window.
	mut w := ui.create(
		debug: $if dev ? { true } $else { false }
	)
	w.set_title('Astro + V + webview')
	w.set_size(800, 600, .@none)

	// Bind V functions.
	w.bind_opt[voidptr]('__open', ui.open)
	w.bind_opt('__increment', increment)

	// Serve the UI.
	ui_path := os.join_path(@VMODROOT, 'ui')
	$if dev ? {
		w.serve_dev(ui_path)!
		// w.serve_dev(ui_path, pkg_manager: .yarn)!
		// w.serve_dev(ui_path, pkg_manager: .pnpm)!
	} $else {
		// After having run e.g., `npm run build` in `ui/`
		w.serve_static(os.join_path(ui_path, 'dist'))!
	}

	// Run and wait until the window gets closed.
	w.run()
	// Destroy the window, clear up resources.
	// In case of running with `-d dev` this also ends the npm background process.
	w.destroy()
}
