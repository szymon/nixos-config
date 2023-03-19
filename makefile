


switch:
	sudo nixos-rebuild switch --impure --flake '.#vbox'


build:
	nixos-rebuild build --impure --flake '.#vbox'

upgrade:
	sudo nixos-rebuild switch --impure --upgrade --flake '.#vbox'
