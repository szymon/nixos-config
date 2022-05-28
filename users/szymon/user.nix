{ pkgs, ... }: {
  environment.pathsToLink = [ "/share/fish" ];
  users.users.szymon = {
    isNormalUser = true;
    home = "/home/szymon";
    extraGroups = [ "docker" "wheel" ];
    shell = pkgs.fish;
    hashedPassword = "$6$YhgqRp.d86wAL/Pn$qN5O0RXFSyQYVBOOKQ5MGvyYXfD2t48LTDM.97w.whmQzq.lUF7UFFqcLTWl9j54aWKp2pP594l7H.3wWTGG71";
  };
}

# vim: set ts=2 sw=2 expandtab :
