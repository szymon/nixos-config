{
  description = "A flake base nixos configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";

      inputs.nixpkgs.follows = "nixpkgs";
    };

    vscode-server.url = "github:msteen/nixos-vscode-server";

  };
  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";
      overlays = [ ];
    in
    {
      nixosConfigurations.vbox = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          { nixpkgs.overlays = overlays; }
          ./hardware.nix
          ./configuration.nix
          ./users/szymon/nixos.nix
#           inputs.vscode-server.nixosModule
#           ({ config, pkgs, ... }: {
#             services.vscode-server.enable = true;
#           })

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.szymon = import ./users/szymon/home-manager.nix;
          }

        ];

      };
    };
}
