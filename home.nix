{ config, pkgs, ... }:

{
  home.username = "mariusl";
  home.homeDirectory = "/home/mariusl";
  home.stateVersion = "25.11";

  # =========================================================================
  # User Packages
  # =========================================================================
  home.packages = with pkgs; [
    # Dev
    neovim
    git
    (pkgs.vscode.override {
      commandLineArgs = [
        "--enable-features=UseOzonePlatform"
        "--ozone-platform=wayland"
      ];
    })
    # Apps
    vesktop
    kdePackages.kate
    libreoffice-fresh
    xournalpp
    gparted
    rar
    brave
    naps2

    # Utilities
    htop
    rustdesk

    #Fonts
    inter
    montserrat
    jetbrains-mono

    # Custom build & push script
    (pkgs.writeShellScriptBin "rebuild-and-push" ''
      #!/bin/sh
      # Abort script on any error
      set -e

      # --- Configuration (Adjust if needed) ---
      CONFIG_DIR="$HOME/nixos-config"  # 1. Path to your Git repository
      FLAKE_TARGET=".#nixos"          # 2. Your flake output (from your 'update' alias)
      REMOTE="origin"                  # 3. Your Git remote name
      BRANCH="main"                    # 4. Your Git branch name
      # ----------------------------------------

      echo "--> Changing to config directory: $CONFIG_DIR"
      cd "$CONFIG_DIR"

      # 1. Add and commit changes
      echo "--> Staging all changes..."
      ${pkgs.git}/bin/git add .

      if ${pkgs.git}/bin/git diff --staged --quiet; then
        echo "--> No configuration changes to commit."
      else
        echo "--> Creating Git commit..."
        ${pkgs.git}/bin/git commit -m "NixOS: Config Update $(date +'%Y-%m-%d %H:%M:%S')"
      fi

      # 2. Build the system
      echo "--> Building NixOS system (target: $FLAKE_TARGET)..."
      if sudo nixos-rebuild switch --flake "$FLAKE_TARGET"; then
        # 3. Push on success
        echo "--> Build successful. Pushing to remote '$REMOTE'..."
        ${pkgs.git}/bin/git push "$REMOTE" "$BRANCH"
        echo "--> Synchronization complete!"
      else
        # 4. Warn on failure
        echo "!!! NixOS build FAILED! !!!"
        echo "--> The faulty commit will NOT be pushed."
      fi
    '')

    # build without pushing to git
      (pkgs.writeShellScriptBin "rebuild" ''
      #!/bin/sh
      # Abort script on any error
      set -e

      # --- Configuration (Adjust if needed) ---
      CONFIG_DIR="$HOME/nixos-config"  # 1. Path to your Git repository
      FLAKE_TARGET=".#nixos"          # 2. Your flake output (from your 'update' alias)
      # ----------------------------------------

      echo "--> Changing to config directory: $CONFIG_DIR"
      cd "$CONFIG_DIR"

      echo "--> Building NixOS system (target: $FLAKE_TARGET)..."
      if sudo nixos-rebuild switch --flake "$FLAKE_TARGET"; then
        echo "--> Build successful."
      else
        echo "!!! NixOS build FAILED! !!!"
      fi
    '')
  ];

  # =========================================================================
  # Program Configurations
  # =========================================================================
  programs.bash = {
    enable = true;
    shellAliases = {
      ll = "ls -l";
      # 'update' alias now points to the safe, version-controlled script
      update = "rebuild-and-push";
      edit-nix = "kate ~/nixos-config/configuration.nix ~/nixos-config/home.nix &";

    };
  };

  programs.firefox = {
    enable = true;
    # Firefox settings and profiles can be configured here
  };

  # Other program configurations can be added here
}
