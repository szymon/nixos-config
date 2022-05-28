name: { nixpkgs, home-manager, system, user, overlays }:

nixpkgs.lib.nixosSystem rec {

  inherit system;

  modules = [
    { nixpkgs.overlays = overlays; }
    ./hardware.nix
    ./machines/${name}.nix
    # TODO(szymon): add option for passing username
    ./users/szymon/user.nix

    home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.szymon = import ./users/szymon/home-manager.nix;
    }

  ];

  # TODO(szymon): deprication warning
  extraArgs = {
    currentSystemName = name;
    currentSystem = system;
  };
}

