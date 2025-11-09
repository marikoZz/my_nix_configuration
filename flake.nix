{
  description = "Marius's NixOS System Configuration"; # [cite: 1]

  # =========================================================================
  # Flake Inputs
  # =========================================================================
  inputs = {
    # Nix Packages (Unstable)
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable"; # [cite: 1]

    # Home Manager
    home-manager.url = "github:nix-community/home-manager"; # [cite: 2]
    home-manager.inputs.nixpkgs.follows = "nixpkgs"; # [cite: 2]

    # Other inputs can be added here [cite: 3]
  };

  # =========================================================================
  # Flake Outputs
  # =========================================================================
  outputs = { self, nixpkgs, home-manager, ... }@inputs: {

    # NixOS System Configuration
    nixosConfigurations = {
      # This is the primary system configuration, referenced as .#nixos
      "nixos" = nixpkgs.lib.nixosSystem { #
        system = "x86_64-linux"; #
        modules = [
          # 1. Import the main system configuration
          ./configuration.nix # [cite: 4]

          # 2. Integrate Home Manager as a NixOS module
          home-manager.nixosModules.home-manager # [cite: 4]
          {
            home-manager.useGlobalPkgs = true; # [cite: 4]
            home-manager.useUserPackages = true; # [cite: 5]
            # 3. Define the user and import their specific config
            home-manager.users.mariusl = import ./home.nix; # [cite: 5]
          }
        ];
      };
    };
  };
}
