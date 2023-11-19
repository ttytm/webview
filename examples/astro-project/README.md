# Astro + V + webview

This example uses Astro for the UI.
The readme below shows how to run it in a development environment or built into a static site.
The process works with `npm`, `yarn` or `pnpm`.

<div align="center">
  <img width="840" alt="Screenshot" src="https://github.com/ttytm/webview/assets/34311583/17a4fbe6-e27b-4f05-8841-21086994708c">
</div>

## Run

> [!NOTE]
> This example uses npm by default.
> When switching to another package manager, you can delete the current package lock file, i.e.
> `package-lock.json` for npm and, if you've already run the package manager's install command,
> the `npm_modules` directory.

Move into the examples directory

```sh
cd examples/astro-project
```

<details open>
<summary><b>Npm</b></summary>

- Install the dependencies

  ```sh
  npm --prefix ui i
  ```

- Run the app in a development environment. E.g., this enables the web-inspector and hot-reload of
  the webview window while working on the UI

  ```sh
  v -d dev run .
  ```

- Build the UI into a static output and run the app

  ```sh
  npm --prefix ui run build
  ```

  ```sh
  v run .
  ```

</details>
<details>
<summary><b>yarn</b></summary>

- Update `src/main.v`

  https://github.com/ttytm/webview/blob/14e87cdc771943fb8b6381bfd737f6a26250cbd7/examples/astro-project/src/main.v#L23-L25

  ```v
  // w.serve_dev(ui_path)!
  w.serve_dev(ui_path, pkg_manager: .yarn)! // <- specify yarn as package manager.
  ```

- Install the dependencies

  ```sh
  yarn --cwd ui
  ```

- Run the app in a development environment. E.g., this enables the web-inspector and hot-reload of
  the webview window while working on the UI

  ```sh
  v -d dev run .
  ```

- Build the UI into a static output and run the app

  ```sh
  yarn --cwd ui run build
  ```

  ```sh
  v run .
  ```

</details>
<details>
<summary><b>Pnpm</b></summary>

- Update `src/main.v`

  https://github.com/ttytm/webview/blob/14e87cdc771943fb8b6381bfd737f6a26250cbd7/examples/astro-project/src/main.v#L23-L25

  ```v
  // w.serve_dev(ui_path)!
  w.serve_dev(ui_path, pkg_manager: .pnpm)! // <- specify pnpm as package manager.
  ```

- Install the dependencies

  ```sh
  pnpm --prefix ui i
  ```

- Run the app in a development environment. E.g., this enables the web-inspector and hot-reload of
  the webview window while working on the UI

  ```sh
  v -d dev run .
  ```

- Build the UI into a static output and run the app

  ```sh
  pnpm --prefix ui run build
  ```

  ```sh
  v run .
  ```

</details>
