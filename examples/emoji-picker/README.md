# Emoji Picker Example

An emoji picker desktop application that's less than 1 MB in size and less than 100 lines of code -
including customizations.

<div align="center">
  <img width="412" src="https://github.com/ttytm/webview/assets/34311583/b4e4f473-c40e-4df0-9819-2a6cb04ddfa8">
</div>

This example utilizes the awesome work of: https://github.com/missive/emoji-mart

## Run

From the examples directory

```sh
v run main.v
```

Or from webview src directory

```sh
v run examples/emoji-picker/main.v
```

## Compile a "release" binary

From the examples directory

```sh
v -cc clang -prod main.v -o emoji-picker
```

Or from webview src directory

```sh
v -cc clang -prod examples/emoji-picker/main.v -o examples/emoji-picker/emoji-picker
```

An extended example that integrates an emoji picker into a desktop application with a SveleteKit
GUI is: [ttytm/emoji-mart-desktop](https://github.com/ttytm/emoji-mart-desktop)
