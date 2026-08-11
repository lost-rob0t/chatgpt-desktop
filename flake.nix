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

      apps.${system}.default = {
        type = "app";
        program = "${chatgpt-desktop}/bin/chatgpt";
      };
    };
}
