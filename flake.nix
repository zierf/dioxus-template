{
  description = "Dioxus Template";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    supportedSystems.url = "github:nix-systems/default-linux";
  };

  outputs =
    {
      self,
      nixpkgs,
      ...
    }@inputs:
    let
      # see examples for Nix Flake template and basic usage for nix-systems
      # https://github.com/nix-systems/nix-systems?tab=readme-ov-file#basic-usage
      # https://github.com/NixOS/templates/blob/master/python/flake.nix
      eachSystem = nixpkgs.lib.genAttrs (import inputs.supportedSystems);

      pkgs = eachSystem (system: nixpkgs.legacyPackages.${system});

      tagstudioApp = eachSystem (
        system:
        pkgs.${system}.rustPlatform.buildRustPackage {
          pname = "dioxus-template";
          version = "0.1.0";

          cargoLock = {
            lockFile = ./Cargo.lock;
          };
        }
      );
    in
    {
      formatter = eachSystem (system: pkgs.${system}.nixfmt-rfc-style);

      # Development Shell.
      # $> nix develop
      devShells = eachSystem (system: {
        default = pkgs.${system}.mkShell {
          buildInputs = with pkgs.${system}; [
            atkmm
            cargo
            clippy
            dioxus-cli
            gtk3
            libsoup_3
            pango
            pkg-config
            rust-analyzer
            rustc
            rustfmt
            llvmPackages.bintools
            webkitgtk_4_1
            xdotool
          ];

          RUST_BACKTRACE = 1;

          # https://discourse.nixos.org/t/rust-src-not-found-and-other-misadventures-of-developing-rust-on-nixos/11570/3?u=samuela
          RUST_SRC_PATH = "${pkgs.${system}.rust.packages.stable.rustPlatform.rustLibSrc}";

          #shellHook = '''';
        };
      });
    };
}
