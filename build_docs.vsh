#!/usr/bin/env -S v

import regex

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

build_docs() or {
	eprintln('Failed building docs. ${err}')
	exit(1)
}
