---
title: Stop Breaking Things: A Gentle Introduction to NixOS in the Homelab
description: Creating sustainable, reproducible infrastructure with Nix.
author: Aly Raffauf
keywords: nix, nixos, homelab, nixpkgs, flakes
# url: https://marp.app/
# image: https://marp.app/og-image.jpg
marp: true
---

# Stop Breaking Things:

## A Gentle Introduction to NixOS in the Homelab

### Aly Raffauf

---

## The Problem

![this is fine (room burning)](./img/thisisfine.png)

---

## The Problem (2)

- Things break.
- We don't remember how to fix them.
- We don't even know if they're broken.
- It takes a long time to fix them.
- Our mean time to recovery (MTTR) sucks.

---

## What We Need

- lol
- lol
- fffkdbfjknvfj rkjndfkjdn jkdfs

---

## The Solution(s)

---

## Bash

- Writing good Bash is really hard.
- It doesn't scale well.
- BYO rollbacks.
- writing good Bash is hard

---

## Ansible

- Looks declarative, but isn't really.
- Not reliably reproducible.
- BYO rollbacks.
- YAML

---

![nix logo](./img/nixlogo.png)

---

## What is Nix?

- A collision-free atomic package manager.
- A functional build system.
- A purely functional Turing-complete programming language.
- A script-and-text-file orchestration system (with symlinks).
- A composable linux distribution.

---

## Nix vs Nix vs Nixpkgs vs NixOS

- Nix: a programming language.
- Nix (the implemented package manager, interpreter, build system, daemon)
- nixpkgs - a large monorepository of thousands of
- NixOS - the linux-based

---

![nixos vs nixpkgs vs nix](./img/nixpkgsisnotnixosisnotnix.png)

---

## Understanding Nix

| Imperative                                  | Declarative                                                       |
| ------------------------------------------- | ----------------------------------------------------------------- |
| “Run these _steps_.”                        | “Describe the _state_.”                                           |
| Hidden mutations in `/usr`, `/etc`, `$HOME` | Everything lives in `/nix/store/…` (content-addressed, read-only) |
| Success depends on host history             | Build result depends **only** on declared inputs                  |
| Manual roll-back (if any)                   | Automatic, atomic generations & rollbacks                         |

---

## What are flakes?

- A unified input/output schema for the Nix language.
- Inputs -> logic -> outputs.
- Inputs are locked at a specific git revision in a flake.lock file.
- Flakes + nix allows us to compose reliably reproducible\* outputs.

---

## Flake Inputs

- Other flakes
- Remote git repositories
- Any path (or git repo)

---

## Flake Outputs

- Packages
- Modules
- Docker Containers
- Development Shells
- NixOS configurations
- Home Manager configurations
- Darwin (macOS) configurations

---

## Hello, world!

```nix
{
  description = "Hello, world! with nixpkgs";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }: {
    packages.x86_64-linux.hello = nixpkgs.legacyPackages.x86_64-linux.hello;
  };
}
```

---

## OCI Containers

```nix
{
  description = "Hello, world! with docker";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }: {
    packages.x86_64-linux.dockerHello = nixpkgs.legacyPackages.x86_64-linux.dockerTools.buildImage {
      name = "hello";
      tag = "latest";
      contents = [ nixpkgs.legacyPackages.x86_64-linux.hello ];
      config.Cmd = [ "/bin/hello" ];
    };
  };
}
```
---

## DevShells

```nix
{
  description = "Hello, world! devshell (auto-runs hello)";

  inputs.nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

  outputs = { self, nixpkgs }: {
    devShells.x86_64-linux.default = nixpkgs.legacyPackages.x86_64-linux.mkShell {
      packages = [ nixpkgs.legacyPackages.x86_64-linux.hello ];
      shellHook = ''
        echo "👋 Running hello..."
        hello
      '';
    };
  };
}
```
---

## NixOS
```nix
{
  description = "Minimal NixOS flake";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }: {
    nixosConfigurations.self2025 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [{
        boot.loader.grub.device = "/dev/sda";
        fileSystems."/" = {
          device = "/dev/sda1";
          fsType = "ext4";
        };
        services.openssh.enable = true;
        users.users.root.initialPassword = "nixos";
      }];
    };
  };
}
```

---

## Why?

- Configure everything in a common language

  lkj
