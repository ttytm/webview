# webview - V Binding

[![build-status](https://img.shields.io/github/actions/workflow/status/ttytm/webview/ci.yml?branch=main&style=flat-rounded)](https://github.com/ttytm/webview/actions/workflows/ci.yml?query=branch%3Amain)
[![last-commit](https://img.shields.io/github/last-commit/ttytm/webview?style=flat-rounded)](https://github.com/ttytm/webview)

This repository provides a V binding for [webview](https://github.com/webview/webview) - a tiny cross-platform library
to build modern cross-platform GUI applications. It allows to combine V as a fast, compiled general
purpose programming language with modern web technologies to design a graphical user interface.

## Installation

**Build Tools and WebKit**

- Linux - Example for debian based destributions

  ```sh
  # Build tools, such as a C compiler
  sudo apt install build-essential
  # WebKit
  sudo apt install libgtk-3-dev libwebkit2gtk-4.0-dev
  ```

- macOS

  ```sh
  xcode-select --install
  ```

- Windows

  E.g., https://www.msys2.org/ provides instructions to install MinGW

**V**

- [Installing V from source](https://github.com/vlang/v#installing-v-from-source)

**Webview Module**

- Install the module

  ```sh
  v install ttytm.webview
  ```

- After the installation, build the webview C library to which the webview V module will bind.\
  You can re-run the script at any point to rebuild the parent library with the latest upstream
  changes.

  ```sh
  # Linux/macOS
  v ~/.vmodules/ttytm/webview/build.vsh
  # PowerShell
  v $HOME/.vmodules/ttytm/webview/build.vsh
  ```

## Usage Example

> [!TIP]
> When running and building on Windows, it is recommended to use `gcc` for compilation. E.g.:
>
> ```sh
> v -cc gcc run .
> ```

<br>

```v ignore
import ttytm.webview

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
      // Call a V function that takes an argument and returns a value.
      const res = await window.my_v_func(\'Hello from JS!\');
      console.log(res);
    }
  </script>
</html>'

fn my_v_func(e &webview.Event) string {
	println('Hello from V from V!')
	e.eval("console.log('Hello from V from JS!');")
	str_arg := e.get_arg[string](0) or { '' } // Get string arg at index `0`
	return str_arg + ' Hello back from V!'
}

w := webview.create(debug: true)
w.bind('my_v_func', my_v_func)
w.set_size(600, 400, .@none)
w.set_html(html)
w.run()
```

Output when pressing <kbd>Call V!</kdb>

```
Hello from V from V!
CONSOLE LOG Hello from V from JS!
CONSOLE LOG Hello from JS! Hello back from V!
```

---

### Additional Examples

Examples that can be found in the [`examples/`](https://github.com/ttytm/webview/tree/master/examples) directory of the repository.

1. [v-js-interop-simple](https://github.com/ttytm/webview/tree/main/examples/v-js-interop-simple) - simple example with a similar complexity as the readme example above.
2. [v-js-interop-app](https://github.com/ttytm/webview/tree/main/examples/v-js-interop-app) - shows the basic code architecture of an application.
3. [project-structure](https://github.com/ttytm/webview/tree/main/examples/project-structure) - organizes `2. v-js-interop-app` into a directory structure that can be used as orientation for more complex projects.
4. [astro-project](https://github.com/ttytm/webview/tree/main/examples/astro-project) - uses a modern web framework for the UI.

External Examples

1. [LVbag](https://github.com/ttytm/LVbag/blob/main/examples/gui_project) - minimal example that automates embedding of the UI into the executable.
2. [emoji-mart-desktop](https://github.com/ttytm/emoji-mart-desktop) - application that combines above concepts. It uses SvelteKit for the UI and embeds it inside a single executable.

## Documentation

An overview of exported functions is accessible in the repositories [`src/lib.v`](https://github.com/ttytm/webview/blob/master/src/lib.v)
file and on its [vdoc site](https://ttytm.github.io/webview/webview.html).

### Debugging

> [!NOTE]
> The debug feature currently works on Linux and Windows.

Use the `webview_debug` flag to enable developer tools -
enabling _right click_ <kbd>Inspect Element</kbd> and `console.log` prints to the terminal. E.g.:

```sh
v -d webview_debug run .
```

Alternatively, control the debug mode explicitly for a window by using the debug parameter.

```v ignore
webview.create() // enabled when the application was build with `-d webview_debug`
webview.create(debug: true) // explicitly enabled for the window
webview.create(debug: false) // explicitly disabled for the window, even when built with `-d webview_debug`
```

## Disclaimer

Until a stable version 1.0 is available, new features will be introduced, existing ones may change,
or breaking changes may occur in minor(`0.<minor>.*`) versions.

## Complementary Projects

- [Dialog](https://github.com/ttytm/dialog) - Cross-platform utility library to open system dialogs - files, message boxes etc.
- [LVbag](https://github.com/ttytm/LVbag) - Generate embedded file lists for directories.

## License

Open source software under the MIT license.
