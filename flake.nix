{
  description = "NixOS system and tools by szymon (stolen from github.com/mitchellh/nixos-config)";

  inputs = {
    nixpkgs.url = github:nixos/nixpkgs;
    home-manager = {
      url = github:nix-community/home-manager;
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      configureMachine = import ./configureMachine.nix;
      username = "szymon";

      overlays = [
        inputs.neovim-nightly-overlay.overlay
      ];

    in
    {
      nixosConfigurations.native-x86_64 = configureMachine "native-x86_64" rec {
        inherit overlays nixpkgs home-manager;
        system = "x86_64-linux";
        user = "szymon";
      };


      nixosConfigurations.vm-intel = configureMachine "vm-intel" rec {
        inherit overlays nixpkgs home-manager;
        system = "x86_64-linux";
        user = username;
      };
    };
}
