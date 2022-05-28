name: { nixpkgs, home-manager, system, user, overlays }: nixpkgs.lib.nixosSystem rec {

  inherit system;

  modules = [
    { nixpkgs.overlays = overlays; }
    ./machine.nix
    # ./user.nix

    home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.szymon = import ./home-manager.nix;
    }

  ];

  extraArgs = {
    currentSystemName = name;
    currentSystem = system;
  };
}


# vim: set ts=2 sw=2 expandtab :
