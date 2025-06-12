{
  config,
  pkgs,
  lib,
  ...
}: {
  # 1. Hardware and boot
  imports = [./hardware-configuration.nix];

  boot.loader = {
    efi.canTouchEfiVariables = true;
    systemd-boot.enable = true;
  };

  # 2. Networking and firewall
  networking = {
    hostName = "self2025";
    networkmanager.enable = true;
    firewall.allowedTCPPorts = [80 443];
  };

  # 3. Localization
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "us";

  # 4. Core services
  services = {
    xserver.enable = true;
    openssh.enable = true;
  };

  # 5. Users and per-user packages
  users = {
    users = {
      aly = {
        isNormalUser = true;
        extraGroups = ["wheel"]; # sudo
        packages = with pkgs; [tree];
      };
    };
  };

  # 6. Global environment packages
  environment.systemPackages = with pkgs; [
    helix
    wget
  ];

  # 7. NixOS release compatibility
  system.stateVersion = "25.05";
}
