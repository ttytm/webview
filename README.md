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

- Webkit

  ```
  sudo apt install libgtk-3-dev libwebkit2gtk-4.0-dev
  ```

Install the repository as V module

- From source

  ```
  v install --git https://github.com/ttytm/webview
  ```

- Or as vpm module

  ```
  v install ttytm.webview
  ```

## Usage

> **Note**
> Depending on the installation method, default paths and imports look like:
>
> ```sh
> ~/.vmodules/webview/src/bindings/build.vsh # from source
> ~/.vmodules/ttym/webview/src/bindings/build.vsh # vpm module
> ```

> ```v
> import webview // from source
> import ttytm.webview // vpm module
> ```

Before the first use, we need to build the webview C library to which we are going to bind.

```sh
# Run the included build script
~/.vmodules/webview/src/bindings/build.vsh
```

### Usage Example

```v ignore
import webview

struct App {
	w &webview.Webview
}

const html = '<!DOCTYPE html>
<html lang="en">
	<head>
		<style>
			body {
				background-color: SlateGray;
				color: GhostWhite;
				text-align: center;
			}
		</style>
	</head>
	<body>
		<h1>My App Content!</h1>
		<button onclick="my_v_func()">Call V!</button>
	</body>
</html>'

fn my_v_func(event_id &char, args &char, app &App) {
	println('Hello From V!')
}

mut app := App{
	w: webview.create(debug: true)
}
app.w.bind('my_v_func', my_v_func, app)
app.w.set_size(600, 400, .@none)
app.w.set_html(html)
app.w.run()
```

Extended examples can be found in the [examples](https://github.com/ttytm/webview/tree/master/examples) directory.
An application example that uses this webview binding with SvelteKit for the UI is [emoji-mart-desktop](https://github.com/ttytm/emoji-mart-desktop).

The overview of exported functions is accessible in the repositories [`src/lib.v`](https://github.com/ttytm/webview/blob/master/src/lib.v)
file and on its [vdoc](https://ttytm.github.io/webview/) site.
