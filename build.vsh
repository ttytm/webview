#!/usr/bin/env -S v

import cli
import os
import time
import net.http
import regex

const (
	lib_url = 'https://raw.githubusercontent.com/webview/webview/master'
	lib_dir = '${@VMODROOT}/src'
)

// == Docs ====================================================================

fn rm_readme_section(html string) string {
	mut r := regex.regex_opt(r'<h1>webview - V Binding</h1>.*</section>') or { panic(err) }
	sec_start, sec_end := r.find(html)
	return '${html[..sec_start]}</section>${html[sec_end..]}'
		.replace('<li class="open"><a href="#readme_webview">README</a></li>', '')
}

fn move_copy_char_section(html string) string {
	// Find initial copy_char section
	mut r := regex.regex_opt(r'<section id="copy_char" class="doc-node">.*</section>\s</section>') or {
		panic(err)
	}
	sec_start, sec_end := r.find(html)
	// Store copy_char section with its content
	copy_char_sec := html[sec_start..sec_end]
	// Delete copy_char section at it's original position
	mut result := r.replace(html, '')
	// Find target section
	r = regex.regex_opt(r'<section id="Hint" class="doc-node">') or { panic(err) }
	target_start, _ := r.find(result)
	// Insert copy_char section before target section
	return '${result[..target_start]}${copy_char_sec}\n\t${result[target_start..]}'
}

fn move_copy_char_menu_item(html string) string {
	mut r := regex.regex_opt(r'<li class="open"><a href="#copy_char">.*</li>') or { panic(err) }
	menu_item_start, menu_item_end := r.find(html)
	menu_item := html[menu_item_start..menu_item_end]
	mut result := r.replace(html, '')
	r = regex.regex_opt(r'<li class="open"><a href="#Hint">') or { panic(err) }
	target_start, _ := r.find(result)
	return '${result[..target_start]}${menu_item}\n\t${result[target_start..]}'
}

fn build_docs() ! {
	res := execute('v doc -readme -m -f html .')
	if res.exit_code != 0 {
		eprintln(res.output)
		exit(1)
	}
	mut webview_html := read_file('_docs/webview.html')!
	webview_html = rm_readme_section(webview_html)
	webview_html = move_copy_char_section(webview_html)
	webview_html = move_copy_char_menu_item(webview_html)
	write_file('_docs/webview.html', webview_html)!
}

// == Libs ====================================================================

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

[if windows]
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
	http.download_file('${lib_url}/webview.h', '${lib_dir}/webview.h') or { panic(err) }
	http.download_file('${lib_url}/webview.cc', '${lib_dir}/webview.cc') or { panic(err) }
	download_webview2()
	dl_spinner <- true
}

fn build(silent bool) {
	mut cmd := 'g++ -c ${lib_dir}/webview.cc -o ${lib_dir}/webview.o'
	cmd += $if darwin && amd64 { ' -std=c++11' } $else { ' -std=c++17' }
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
	println('\rSuccessfully built webview library.')
}

fn run(cmd cli.Command) ! {
	// Remove old library files
	execute('rm ${lib_dir}/webview.*')
	silent := cmd.flags[0].get_bool()!
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
