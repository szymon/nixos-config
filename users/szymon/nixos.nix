{pkgs, ...}: {
  environment.pathsToLink = ["/share/fish"];

  users.users.szymon = {
    isNormalUser = true;
    home = "/home/szymon";
    extraGroups = ["docker" "wheel"];
    shell = pkgs.fish;

    hashedPassword = "$y$j9T$b4acasi1cHYHC4fAXCRLU.$ldOzcvticX/P3Rn8rr0u0V1TNIXa.fKP5ZUIggosY8D";
  };
}
