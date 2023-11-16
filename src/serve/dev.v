module serve

import os
import term

pub enum PackageManger {
	npm
	yarn
	pnpm // Good technology but too woke author. Usage not recommended.
}

// serve_dev uses the given package manger to run the given script name and
// navigates to the localhost address on which the application is served.
pub fn serve_dev(ui_path string, pkg_manager PackageManger, script_name string) !(&os.Process, int) {
	npm_path := os.find_abs_path_of_executable(pkg_manager.str()) or {
		eprintln('failed to find ${pkg_manager}.\nMake sure  is executable.')
		exit(0)
	}
	mut p := os.new_process(npm_path)
	p.use_pgroup = true
	p.set_work_folder(ui_path)
	p.set_redirect_stdio()
	if pkg_manager == .pnpm {
		p.set_args([script_name])
	} else {
		p.set_args(['run', script_name])
	}
	p.run()
	mut port := 0
	for p.is_alive() {
		line := p.stdout_read()
		if line.contains('127.0.0.1:') {
			port = term.strip_ansi(line.all_after('127.0.0.1:').trim_space()).int()
			break
		} else if line.contains('localhost:') {
			port = term.strip_ansi(line.all_after('localhost:').trim_space()).int()
			break
		}
	}
	if port == 0 {
		p.signal_pgkill()
		return error('failed to run `${pkg_manager} ${p.args.join(' ')}` in `${ui_path}`.')
	}
	return p, port
}
