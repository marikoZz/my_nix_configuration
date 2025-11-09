{ config, pkgs, ... }:

{
  home.username = "mariusl"; # [cite: 1]
  home.homeDirectory = "/home/mariusl"; # [cite: 1]
  home.stateVersion = "23.11"; # [cite: 1]

  # =========================================================================
  # User Packages
  # =========================================================================
  home.packages = with pkgs; [
    # Dev
    neovim # [cite: 3]
    git # [cite: 3]
    vscode # [cite: 3]

    # Apps
    vesktop # [cite: 3]
    kdePackages.kate # [cite: 3]
    libreoffice-fresh # [cite: 3]

    # Utilities
    htop # [cite: 3]

    # Custom build & push script
    (pkgs.writeShellScriptBin "rebuild-and-push" ''
      #!/bin/sh
      # Abort script on any error
      set -e

      # --- Configuration (Adjust if needed) ---
      CONFIG_DIR="$HOME/nixos-config"  # 1. Path to your Git repository
      FLAKE_TARGET=".#nixos"          # 2. Your flake output (from your 'update' alias) [cite: 5]
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
  ];

  # =========================================================================
  # Program Configurations
  # =========================================================================
  programs.bash = {
    enable = true; # [cite: 4]
    shellAliases = {
      ll = "ls -l"; # [cite: 4]
      # 'update' alias now points to the safe, version-controlled script
      update = "rebuild-and-push";
      edit-nix = "kate ~/nixos-config/configuration.nix ~/nixos-config/home.nix &";
    };
  };

  programs.firefox = {
    enable = true; # [cite: 5]
    # Firefox settings and profiles can be configured here [cite: 6]
  };

  # Erstellt eine globale Flag-Datei für VSCode.
  # Diese wird *immer* gelesen, egal wie VSCode gestartet wird.
  home.file.".config/code-flags.conf" = {
    text = ''
      # Jedes Flag in eine eigene Zeile
      --enable-features=UseOzonePlatform
      --ozone-platform=wayland
    '';
  };

  # Other program configurations can be added here
}
