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
  boot.loader.systemd-boot.enable = true; # [cite: 8]

  # =========================================================================
  # Networking
  # =========================================================================
  networking.hostName = "nixos"; # [cite: 7]
  networking.networkmanager.enable = true; # [cite: 7]

  # =========================================================================
  # Internationalisation & Localisation
  # =========================================================================
  time.timeZone = "Europe/Berlin"; # [cite: 7]

  # Fix time conflicts with Windows in Dual-Boot setups
  time.hardwareClockInLocalTime = true;

  i18n.defaultLocale = "de_DE.UTF-8"; # [cite: 7]
  i18n.extraLocaleSettings = { # [cite: 9]
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8"; # [cite: 10]
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  console.keyMap = "de"; # [cite: 7]

  # =========================================================================
  # Desktop Environment (GNOME)
  # =========================================================================
  services = {
    xserver.enable = true; # [cite: 11]
    displayManager.gdm.enable = true; # [cite: 11]
    desktopManager.gnome.enable = true; # [cite: 11]
    xserver.xkb = { # [cite: 12]
      layout = "de";
      variant = "";
    };

    # Enable experimental features like fractional scaling
    xserver.displayManager.setupCommands = ''
      gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"
    ''; # [cite: 11]
  };

  # =========================================================================
  # Audio (PipeWire)
  # =========================================================================
  security.rtkit.enable = true; # [cite: 13]
  services.pipewire = {
    enable = true; # [cite: 13]
    alsa.enable = true; # [cite: 13]
    alsa.support32Bit = true; # [cite: 14]
    pulse.enable = true; # [cite: 14]
  };

  # Disable PulseAudio as PipeWire provides compatibility
  services.pulseaudio.enable = false; # [cite: 13]

  # =========================================================================
  # User Configuration
  # =========================================================================
  users.users.mariusl = {
    isNormalUser = true; # [cite: 15]
    description = "Marius Lange"; # [cite: 15]
    extraGroups = [ "networkmanager" "wheel" "scanner" "lp" ]; # [cite: 15]
    # User packages are managed via home.nix
  };

  # =========================================================================
  # Login & Display Management
  # =========================================================================
  services.displayManager.autoLogin = {
    enable = true; # [cite: 16]
    user = "mariusl"; # [cite: 16]
  };

  # Disable unused TTYs for faster boot and security
  systemd.services."getty@tty1".enable = false; # [cite: 16]
  systemd.services."autovt@tty1".enable = false; # [cite: 16]

  # =========================================================================
  # Package Management & Nix Settings
  # =========================================================================
  nixpkgs.config.allowUnfree = true; # [cite: 17]

  # Enable Flakes and the new nix command
  nix.settings.experimental-features = [ "nix-command" "flakes" ]; # [cite: 19]

  # =========================================================================
  # System-wide Programs (with services)
  # =========================================================================
  programs.steam.enable = true; # [cite: 17]

  # =========================================================================
  # System Packages
  # =========================================================================
  # System-critical packages or tools
  environment.systemPackages = with pkgs; [
    # e.g. wget, curl, git (if not in home.packages)
  ]; # [cite: 18]

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
    webInterface = true; # (Für http://localhost:631)

    # WICHTIG: Aktiviert "driverless" Drucken über Netzwerk-Erkennung
    browsing = true;
    extraConfig = ''
      BrowseLocalProtocols dnssd
    '';
    # Wir brauchen die 'drivers' Sektion NICHT MEHR.
  };

  # 2. Avahi (Zeroconf/Bonjour) aktivieren
  # Das ist der Dienst, der AirPrint-Geräte im Netzwerk findet.
  services.avahi = {
    enable = true;
    nssmdns = true; # Wichtig für die Namensauflösung (.local Adressen)
    publish = {
      enable = true;
      addresses = true;
      workstation = true; # <-- KORREKTE OPTION statt 'services'
      # (Das 'ssh' lassen wir der Einfachheit halber weg,
      # es ist für den Drucker nicht nötig)
    };
  };

  # 3. Brother Scan-Treiber (brscan5) - BLEIBT GLEICH
  # (Scannen ist ein anderes Protokoll und braucht den Treiber)
  hardware.sane.brscan5 = {
    enable = true;
    netDevices = [
      {
        name = "Brother-Scanner";
        # IP-Adresse deines Druckers hier eintragen!
        ip = "192.168.0.144";
      }
    ];
  };
}
