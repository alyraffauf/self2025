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
