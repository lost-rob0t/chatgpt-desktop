{
  description = "Nix package for the official ChatGPT desktop app for Linux";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      chatgpt-desktop = pkgs.callPackage ./package.nix { };
    in
    {
      packages.${system} = {
        default = chatgpt-desktop;
        inherit chatgpt-desktop;
      };

      checks.${system}.runtime-linkage = pkgs.runCommand "chatgpt-runtime-linkage" {
        nativeBuildInputs = [ pkgs.patchelf ];
      } ''
        app=${chatgpt-desktop}/lib/chatgpt
        loader=$(patchelf --print-interpreter "$app/ChatGPT")
        for binary in "$app/ChatGPT" "$app/resources/native/remote-control-device-key.node"; do
          "$loader" --list "$binary" > linkage.txt 2>&1 || { cat linkage.txt; exit 1; }
          cat linkage.txt
          if grep -q 'not found' linkage.txt; then
            exit 1
          fi
        done
        touch "$out"
      '';

      apps.${system}.default = {
        type = "app";
        program = "${chatgpt-desktop}/bin/chatgpt";
      };
    };
}
