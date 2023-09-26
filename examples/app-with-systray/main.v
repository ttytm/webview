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

fn create_tray() {
	mut systray := Tray{
		tray: vtray.VTrayApp{
			identifier: 'VTray!'
			tooltip: 'VTray Demo!'
			icon: '${@VMODROOT}/assets/icon.ico'
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
	}
	systray.tray.on_click = systray.on_click
	systray.tray.vtray_init()
	systray.tray.run()
	systray.tray.destroy()
}

// on_click -> This is the tray event listener
// which will give you an id that you can use to handle
// your tray logic.
fn (systray &Tray) on_click(menu_id int) {
	match menu_id {
		int(MenuItems.edit) {
			println('EDIT!')
		}
		int(MenuItems.quit) {
			systray.tray.destroy()
		}
		else {}
	}
}

fn main() {
	w := webview.create(debug: true)
	w.set_title('VTray Example!')
	w.set_size(600, 400, .@none)
	w.navigate('file://${@VMODROOT}/index.html')
	spawn create_tray()
	w.run()
	w.destroy()
}
