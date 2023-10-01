module main

import webview
import ouri028.vtray

enum MenuItems {
	edit = 1
	quit = 2
}

struct Tray {
	pub mut:
	tray vtray.VTrayApp
}

fn main() {
	mut systray := &vtray.VTrayApp{
		identifier: 'VTray!'
		tooltip: 'VTray Demo!'
		icon: '${@VMODROOT}/assets/icon.png'
		items: [
			&vtray.VTrayMenuItem{
				id: int(MenuItems.edit)
				text: 'Edit'
			},
			&vtray.VTrayMenuItem{
				id: int(MenuItems.quit)
				text: 'Quit'
			},
		]
	}
	on_click := fn [systray] (menu_id int) {
		match menu_id {
			int(MenuItems.edit) {
				println('EDIT!')
			}
			int(MenuItems.quit) {
				systray.destroy()
			}
			else {}
		}
	}
	systray.on_click = on_click
	systray.vtray_init()
	w := webview.create(debug: true)
	w.set_title('VTray Example!')
	w.set_size(600, 400, .@none)
	w.navigate('file://${@VMODROOT}/index.html')
	spawn systray.run()
	w.run()
	w.destroy()
	systray.destroy()
}
