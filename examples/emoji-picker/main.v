import webview
import os

const sound_file_path = '${@VMODROOT}/assets/pop.wav'

fn play_sound(_ &webview.Event) {
	$if linux {
		spawn os.execute('aplay ${sound_file_path}')
	} $else $if macos {
		spawn os.execute('afplay ${sound_file_path}')
	}
}

w := webview.create(debug: true)
w.set_title('Emoji Picker')
w.set_size(352, 435, .@none)
w.bind('play_sound', play_sound)
w.navigate('file://${@VMODROOT}/index.html')
w.run()
w.destroy()
