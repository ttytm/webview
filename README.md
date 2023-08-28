# webview - V Binding

[![build-status](https://img.shields.io/github/actions/workflow/status/ttytm/webview/ci.yml?branch=main&style=flat-rounded)](https://github.com/ttytm/webview/actions/workflows/ci.yml?query=branch%3Amain)
[![last-commit](https://img.shields.io/github/last-commit/ttytm/webview?style=flat-rounded)](https://github.com/ttytm/webview)

This repository provides a V binding for [webview](https://github.com/webview/webview) - a tiny cross-platform library
to build modern cross-platform GUI applications. It allows to combine V as a fast, compiled general
purpose programming language with modern web technologies to design a graphical user interface.

## Installation

Prerequisites

- V

  [Installing V from source](https://github.com/vlang/v#installing-v-from-source)

- WebKit

  E.g., on a debian based Linux destribution

  ```sh
  sudo apt install libgtk-3-dev libwebkit2gtk-4.0-dev
  ```

  On macOS you should be good to go with developer tools installed

  ```sh
  xcode-select --install
  ```

Install the repository as V module

- From source

  ```sh
  v install --git https://github.com/ttytm/webview
  ```

- Or as vpm module

  ```sh
  v install ttytm.webview
  ```

## Usage

After the installation, build the webview C library to which the webview V module will bind.\
You can re-run the script at any point to rebuild the library with the latest upstream changes.

```sh
# For installations from source
~/.vmodules/webview/build.vsh
# For installations as vpm module
~/.vmodules/ttytm/webview/build.vsh
# PowerShell might require to prefix the script with `v run`, e.g.:
v run $HOME/.vmodules/webview/build.vsh
```

### Usage Example

> **Note**
> When running and building on Windows, it is recommended to use `gcc` for compilation. E.g.:
>
> ```sh
> v -cc gcc run .
> ```

<br>

```v ignore
import webview // For installations from source
// import ttytm.webview // For installations as vpm module

const html = '<!DOCTYPE html>
<html lang="en">
	<head>
		<style>
			body {
				background: linear-gradient(to right, #274060, #1B2845);
				color: GhostWhite;
				font-family: sans-serif;
				text-align: center;
			}
		</style>
	</head>
	<body>
		<h1>Your App Content!</h1>
		<button onclick="callV()">Call V!</button>
	</body>
	<script>
		async function callV() {
			console.log(await window.my_v_func(\'Hello from JS!\'));
		}
	</script>
</html>'

fn my_v_func(e &webview.Event) {
	println('Hello from V from V!')
	e.eval("console.log('Hello from V from JS!');")
	str_arg := e.string(0) // Get string arg at index `0`
	e.@return(str_arg + ' Hello back from V!')
}

w := webview.create(debug: true)
w.bind('my_v_func', my_v_func)
w.set_size(600, 400, .@none)
w.set_html(html)
w.run()
```

Extended examples can be found in the [examples](https://github.com/ttytm/webview/tree/master/examples) directory.
An application example that uses this webview binding with SvelteKit for the UI is [emoji-mart-desktop](https://github.com/ttytm/emoji-mart-desktop).

The overview of exported functions is accessible in the repositories [`src/lib.v`](https://github.com/ttytm/webview/blob/master/src/lib.v)
file and on its [vdoc site](https://ttytm.github.io/webview/webview.html).

## Disclaimer

Until a stable version 1.0 is available, new features will be introduced, existing ones may change,
or breaking changes may occur in minor(`0.<minor>.*`) versions.
