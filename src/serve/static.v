module serve

import net
import vweb
import os

struct Context {
	vweb.Context
}

// serve_static serves a UI that has been built into a static site on localhost and
// navigates to it address. Optionally, a port can be specified to serve the site.
// By default, the next free port from `4321` is used.
pub fn serve_static(ui_path string, port u16) !u16 {
	if !os.exists(ui_path) {
		return error('failed to find ui path `${ui_path}`.')
	}
	if !os.is_dir(ui_path) {
		return error('ui path `${ui_path}` is not a directory.')
	}
	mut final_port := port
	for {
		if mut l := net.listen_tcp(.ip6, ':${port}') {
			l.close()!
			break
		}
		final_port++
	}
	spawn fn [ui_path, final_port] () {
		mut web_ctx := Context{}
		web_ctx.mount_static_folder_at(ui_path, '/')
		vweb.run(web_ctx, final_port)
	}()
	return final_port
}

fn (mut ctx Context) index() vweb.Result {
	return ctx.html(os.read_file(ctx.static_files['/index.html']) or { panic(err) })
}
