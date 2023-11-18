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
		build_path := os.join_path(ui_path, 'dist')
		w.serve_static(build_path)!
	}

	// Run and wait until the window gets closed.
	w.run()
	// Detroy the window, in case of `-d dev` end npm process, clear up resources.
	w.destroy()
}
