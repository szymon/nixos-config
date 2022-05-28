

flake := .\#vm-intel

switch:
	nixos-rebuild switch --use-remote-sudo --flake '${flake}' --verbose

encrypt:
	openssl aes-256-cbc -e -in fonts.tar -out fonts.tar.enc -pbkdf2

decrypt:
	openssl aes-256-cbc -d -in fonts.tar.enc -out fonts.tar -pbkdf2

install_fonts: decrypt
	mkdir -p ~/.local/share/fonts
	tar xf fonts.tar
	cp -r fonts/ ~/.local/share/fonts/
	fc-cache

clean:
	rm -rf fonts
	rm fonts.tar
