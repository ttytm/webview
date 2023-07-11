#!/usr/bin/env -S v

import net.http

const (
	lib_url = 'https://raw.githubusercontent.com/webview/webview/master'
	lib_dir = '${@VMODROOT}/src/bindings'
)

fn main() {
	println('Building webview library...')

	execute('rm ${lib_dir}/webview.*')

	http.download_file('${lib_url}/webview.h', '${lib_dir}/webview.h') or { panic(err) }
	http.download_file('${lib_url}/webview.cc', '${lib_dir}/webview.cc') or { panic(err) }

	mut cmd := 'g++ -c ${lib_dir}/webview.cc -std=c++17 -o ${lib_dir}/webview.o'
	$if linux {
		cmd += ' $(pkg-config --cflags gtk+-3.0 webkit2gtk-4.0)'
	}
	comp_res := execute(cmd)
	if comp_res.exit_code != 0 {
		eprintln(comp_res.output)
		exit(1)
	}

	println('Finished.')
}
