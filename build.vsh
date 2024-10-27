#!/usr/bin/env -S v

import cli
import os
import time
import net.http
import regex

const lib_dir = '${@VMODROOT}/src'
const cxx = if _ := find_abs_path_of_executable('g++') {
	'g++'
} else if _ := find_abs_path_of_executable('clang++') {
	'clang++'
} else {
	panic("Can't find C++ compiler. Make sure g++ or clang++ is executable.")
}

// == Build Docs ==============================================================

// Remove redundant readme section from module page.
fn rm_readme_section(html string) string {
	mut r := regex.regex_opt(r'<section id="readme_webview".*</section>') or { panic(err) }
	sec_start, sec_end := r.find(html)
	return '${html[..sec_start]}</section>${html[sec_end..]}'
		.replace('<li class="open"><a href="#readme_webview">README</a></li>', '')
}

fn build_docs() ! {
	// Cleanup old docs.
	rmdir_all('_docs') or {}
	// Build docs.
	mut p := new_process(@VEXE)
	p.set_args(['doc', '-readme', '-m', '-f', 'html', '.'])
	p.wait()
	// Prepare html.
	mut webview_html := read_file('_docs/webview.html')!
	webview_html = rm_readme_section(webview_html)
	write_file('_docs/webview.html', webview_html)!
}

// == Download & Build Library ================================================

fn spinner(ch chan bool) {
	runes := [`-`, `\\`, `|`, `/`]
	mut pos := 0
	for {
		mut finished := false
		ch.try_pop(mut finished)
		if finished {
			print('\r')
			return
		}
		if pos == runes.len - 1 {
			pos = 0
		} else {
			pos += 1
		}
		print('\r${runes[pos]}')
		flush()
		time.sleep(100 * time.millisecond)
	}
}

@[if windows]
fn download_webview2() {
	http.download_file('https://www.nuget.org/api/v2/package/Microsoft.Web.WebView2',
		'${lib_dir}/webview2.zip') or { panic(err) }
	unzip_res := execute('powershell -command Expand-Archive -LiteralPath ${lib_dir}/webview2.zip -DestinationPath ${lib_dir}/webview2')
	if unzip_res.exit_code != 0 {
		eprintln(unzip_res.output)
		exit(1)
	}
}

fn download(silent bool) {
	println('Downloading...')
	dl_spinner := chan bool{cap: 1}
	if !silent {
		spawn spinner(dl_spinner)
	}
	http.download_file('https://raw.githubusercontent.com/malisipi/mui/refs/heads/main/webview/webview/webview.h', '${lib_dir}/webview.h') or { panic(err) }
	http.download_file('https://raw.githubusercontent.com/webview/webview/refs/heads/master/core/src/webview.cc', '${lib_dir}/webview.cc') or { panic(err) }
	download_webview2()
	dl_spinner <- true
}

fn build(silent bool) {
	mut cmd := '${cxx} -c ${lib_dir}/webview.cc -DWEBVIEW_STATIC -o ${lib_dir}/webview.o'
	cmd += $if darwin { ' -std=c++11' } $else { ' -std=c++17' }
	$if linux {
		cmd += ' $(pkg-config --cflags gtk+-3.0 webkit2gtk-4.0)'
	} $else $if windows {
		defer {
			// Cleanup
			rm('${lib_dir}/webview2.zip') or {}
			rmdir_all('${lib_dir}/webview2') or {}
		}
		cmd += ' -I${lib_dir}/webview2/build/native/include'
	}
	println('Building...')
	build_spinner := chan bool{cap: 1}
	if !silent {
		spawn spinner(build_spinner)
	}
	build_res := execute(cmd)
	build_spinner <- true
	if build_res.exit_code != 0 {
		eprintln(build_res.output)
		exit(1)
	}
	println('\rSuccessfully built the webview library.')
}

fn run(cmd cli.Command) ! {
	// Remove old library files
	execute('rm ${lib_dir}/webview.*')
	silent := cmd.flags.get_bool('silent')!
	download(silent)
	time.sleep(100 * time.millisecond)
	build(silent)
}

// == Commands ================================================================

mut cmd := cli.Command{
	name: 'build.vsh'
	posix_mode: true
	required_args: 0
	pre_execute: fn (cmd cli.Command) ! {
		if cmd.args.len > cmd.required_args {
			eprintln('Unknown commands ${cmd.args}.\n')
			cmd.execute_help()
			exit(0)
		}
	}
	execute: run
	commands: [
		cli.Command{
			name: 'docs'
			description: 'Build docs used for GitHub pages.'
			execute: fn (_ cli.Command) ! {
				build_docs() or { eprintln('Failed building docs. ${err}') }
			}
		},
	]
	flags: [
		cli.Flag{
			flag: .bool
			name: 'silent'
		},
	]
}
cmd.parse(os.args)
