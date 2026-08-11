# chatgpt-desktop

Nix packaging for the official ChatGPT desktop app for Linux.

## Run

```sh
nix run github:lost-rob0t/chatgpt-desktop
```

## Install

```sh
nix profile install github:lost-rob0t/chatgpt-desktop
```

The flake packages OpenAI's official Linux RPM and exposes `chatgpt` as the default app. The current package target is `x86_64-linux`.
