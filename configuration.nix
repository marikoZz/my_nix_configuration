{ config, pkgs, inputs, ... }:

{
  # =========================================================================
  # System State & Version
  # =========================================================================
  system.stateVersion = "25.11"; # Pin system version

  # =========================================================================
  # Imports
  # =========================================================================
  imports = [
    ./hardware-configuration.nix
    # Note: Home Manager is imported via flake.nix, which is the correct way.
  ];

  # =========================================================================
  # Boot Loader (systemd-boot)
  # =========================================================================
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 3;

  # FIX GPU ERROR WHEN AWAKING FROM SLEEP
  # 1. Neuesten Kernel nutzen (Wichtig für RX 7800 XT)
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # 2. Fix für weiße Streifen nach Suspend
  boot.kernelParams = [ "amdgpu.sg_display=0" ];

  # 3. Firmware Updates
  hardware.enableRedistributableFirmware = true;

  # =========================================================================
  # Networking
  # =========================================================================
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # =========================================================================
  # Internationalisation & Localisation
  # =========================================================================
  time.timeZone = "Europe/Berlin";

  # Fix time conflicts with Windows in Dual-Boot setups
  time.hardwareClockInLocalTime = true;

  i18n.defaultLocale = "de_DE.UTF-8";
  i18n.extraLocaleSettings = { 
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  console.keyMap = "de";

  # =========================================================================
  # Desktop Environment (GNOME)
  # =========================================================================
  services = {
    xserver.enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
    xserver.xkb = {
      layout = "de";
      variant = "";
    };

    # Enable experimental features like fractional scaling
    xserver.displayManager.setupCommands = ''
      gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"
    '';
  };

  # =========================================================================
  # Audio (PipeWire)
  # =========================================================================
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Disable PulseAudio as PipeWire provides compatibility
  services.pulseaudio.enable = false;

  # =========================================================================
  # User Configuration
  # =========================================================================
  users.users.mariusl = {
    isNormalUser = true;
    description = "Marius Lange";
    extraGroups = [ "networkmanager" "wheel" "scanner" "lp" ];
    # User packages are managed via home.nix
  };

  # =========================================================================
  # Login & Display Management
  # =========================================================================
  services.displayManager.autoLogin = {
    enable = true;
    user = "mariusl";
  };

  # Disable unused TTYs for faster boot and security
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # =========================================================================
  # Package Management & Nix Settings
  # =========================================================================
  nixpkgs.config.allowUnfree = true;

  # Enable Flakes and the new nix command
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # =========================================================================
  # System-wide Programs (with services)
  # =========================================================================
  programs.steam.enable = true;

  # =========================================================================
  # System Packages
  # =========================================================================
  # System-critical packages or tools
  environment.systemPackages = with pkgs; [
    # e.g. wget, curl, git (if not in home.packages)
  ];

  # =========================================================================
  # Environment Variables
  # =========================================================================
  environment.sessionVariables = {
    # Example:
    # NIXOS_OZONE_WL = "1";
  };

  # =========================================================================
  # Drucker & Scanner (Brother MFC J5345DW)
  # =========================================================================

  # 1. Druck-Service (CUPS) mit AirPrint (Treiberlos)
  services.printing = {
    enable = true;
    webInterface = true;
    browsing = true;
    extraConf = ''
      BrowseLocalProtocols dnssd
    '';
  };

  # 2. Avahi (Zeroconf/Bonjour) aktivieren
  # Das ist der Dienst, der AirPrint-Geräte im Netzwerk findet.
  services.avahi = {
    enable = true;
    nssmdns4 = true; # Wichtig für die Namensauflösung (.local Adressen)
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };

  # 3. Brother Scan-Treiber (brscan5)
  hardware.sane.brscan5 = {
    enable = true;
    netDevices = [
      {
        name = "Brother-Scanner";
        # IP-Adresse vom Drucker hier eintragen!
        ip = "192.168.0.144";
      }
    ];
  };

    # 1. Ollama
  services.ollama = {
    enable = true;
  };

  # 2. The AI frontend (the interface)
  services.open-webui = {
    enable = true;
    package = pkgs.open-webui;
  };
}
