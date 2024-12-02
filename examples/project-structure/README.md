# Project Structure Example

This example integrates the [`v-js-interop-app`](https://github.com/ttytm/webview/tree/master/examples/v-js-interop-app) example
into a project structure that can be used as a starting guide for more complex Webview projects.

```
├── assets/
│   └── icon.ico
├── src/
│   ├── api.v
│   ├── main.v
│   └── news.v
├── ui/
│   ├── index.html
│   ├── main.js
│   └── style.css
│── README.md
└── v.mod
```

## Run

From the examples directory

```sh
# ~/<path>/webview/examples/project-structure
v run .
```

Or from webview src directory

```sh
# ~/<path>/webview
v run examples/project-structure/
```
