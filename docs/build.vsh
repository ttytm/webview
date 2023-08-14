#!/usr/bin/env -S v

import regex

fn move_copy_char_section(html string) string {
	// Find initial copy_char section
	mut r := regex.regex_opt(r'<section id="copy_char" class="doc-node">.*</section>') or {
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

fn clean_all() ! {
	rmdir_all('docs/_docs')!
	clean()!
}

fn clean() ! {
	rmdir_all('docs/webview')!
	rm('docs/README.md')!
	rm('docs/build')!
}

fn build_docs() ! {
	mkdir('docs/webview')!
	cp('src/lib.v', 'docs/webview/lib.v')!
	cp('README.md', 'docs/README.md')!
	res := execute('cd docs && v doc -readme -m -f html .')
	if res.exit_code != 0 {
		eprintln(res.output)
		exit(1)
	}
	mut webview_html := read_file('docs/_docs/webview.html')!
	webview_html = move_copy_char_section(webview_html)
	webview_html = move_copy_char_menu_item(webview_html)
	write_file('docs/_docs/webview.html', webview_html)!
}

clean_all()!
build_docs() or {
	eprintln('Failed building docs. ${err}')
	exit(1)
}
clean()!
