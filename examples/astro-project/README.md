# Astro + V + webview

This example uses Astro for the UI.
The readme below shows how to run it in a development environment or built into a static site.
The process works with `npm`, `yarn` or `pnpm`.

## Run

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

  https://github.com/ttytm/webview/blob/3e7f26b82df254871ac21f26d370122f9752e969/examples/astro-project/src/main.v#L22-L24

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

> [!NOTE]
> This example uses npm by default.
> When switching to another package manager, you can delete the current package lock file, i.e.
> `package-lock.json` for npm and, if you've already run the package manager's install command,
> the `npm_modules` directory.
