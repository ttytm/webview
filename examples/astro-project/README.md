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

- Install dependencies

  ```sh
  npm --prefix ui i
  ```

- Run in a development environment - e.g., to enable hot reload in the webview window while

  ```sh
  v -d dev run .
  ```

- Run the static build ui

  ```sh
  npm --prefix ui run build
  ```

  ```sh
  v run .
  ```

</details>
<details>
<summary><b>yarn</b></summary>

- Install dependencies

  ```sh
  yarn --cwd ui
  ```

- Run in a development environment - e.g., to enable hot reload in the webview window while

  ```sh
  v -d dev run .
  ```

- Run the static build ui

  ```sh
  yarn --cwd ui run build
  ```

  ```sh
  v run .
  ```

</details>
<details>
<summary><b>Pnpm</b></summary>

- Install dependencies

  ```sh
  pnpm --prefix ui i
  ```

- Run in a development environment - e.g., to enable hot reload in the webview window while

  ```sh
  v -d dev run .
  ```

- Run static build ui

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
