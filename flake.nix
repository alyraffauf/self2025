{
  description = "Stop Breaking Things: A Gentle Introduction to NixOS in the Homelab";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    allSystems = [
      "aarch64-darwin"
      "aarch64-linux"
      "x86_64-darwin"
      "x86_64-linux"
    ];

    forAllSystems = f:
      nixpkgs.lib.genAttrs allSystems (system:
        f {
          pkgs = import self.inputs.nixpkgs {
            inherit system;
          };
        });
  in {
    apps = forAllSystems ({pkgs}: let
      openSlides = pkgs.writeShellApplication {
        name = "open-slides";
        runtimeInputs = with pkgs; [xdg-utils];

        text = ''
          #!/usr/bin/env bash
          set -euo pipefail

          ${
            if pkgs.stdenv.hostPlatform.isDarwin
            then "open"
            else "xdg-open"
          } ${self.packages.${pkgs.system}.default}/index.html
        '';
      };

    in {
      default = {
        type = "app";
        program = "${openSlides}/bin/open-slides"; # <- string path
      };
    });

    packages = forAllSystems ({pkgs}: {
      default = pkgs.stdenv.mkDerivation {
        buildPhase = ''
          marp index.md
        '';

        installPhase = ''
          mkdir $out
          cp index.html $out/
          cp -r img $out/
        '';

        name = "stop-breaking-things";
        nativeBuildInputs = [pkgs.marp-cli];
        src = self;

        version =
          if self ? shortRev
          then "git-${self.shortRev}"
          else "dev";
      };
    });

    devShells = forAllSystems ({pkgs}: {
      default = pkgs.mkShell {
        packages = with pkgs; [
          alejandra
          marp-cli
          nixd
          nodePackages.prettier
        ];
      };
    });
  };
}
