# Emoji Picker Desktop App

An emoji picker desktop application that's less than 1 MB in size and less than 100 lines of code -
including customizations.

This example utilizes the awesome work of: https://github.com/missive/emoji-mart

```sh
## Run
# from examples directory
v run main.v
# from webview src directory
v run examples/emoji-picker/main.v

## Compile a "release" binary
# from examples directory
v -cc clang -prod main.v -o emoji-picker
# from webview src directory
v -cc clang -prod examples/emoji-picker/main.v -o examples/emoji-picker/emoji-picker
```

<div align="center">
  <img width="412" src="https://github.com/ttytm/webview/assets/34311583/b4e4f473-c40e-4df0-9819-2a6cb04ddfa8">
</div>

An extended example of using a front-end framework instead of importing it from a CDN script is:
[ttytm/emoji-mart-desktop](https://github.com/ttytm/emoji-mart-desktop)
