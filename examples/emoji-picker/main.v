import webview
import os

struct App {
	w &webview.Webview
}

const sound_file_path = '${@VMODROOT}/assets/pop.wav'

fn play_sound(event_id &char, raw_args &char, app &App) {
	$if linux {
		spawn os.execute('aplay ${sound_file_path}')
	} $else $if macos {
		spawn os.execute('afplay ${sound_file_path}')
	}
}

app := App{
	w: webview.create(debug: true)
}

app.w.set_title('Emoji Picker')
app.w.set_size(352, 435, .@none)
app.w.bind('play_sound', play_sound, &app)
app.w.navigate('file://${@VMODROOT}/index.html')
app.w.run()
app.w.destroy()
