{
  description = "Marius's NixOS System Configuration";

  # =========================================================================
  # Flake Inputs
  # =========================================================================
  inputs = {
    # Nix Packages (Unstable)
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home Manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Other inputs can be added here
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
          ./configuration.nix

          # 2. Integrate Home Manager as a NixOS module
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            # 3. Define the user and import their specific config
            home-manager.users.mariusl = import ./home.nix;
          }
        ];
      };
    };
  };
}
