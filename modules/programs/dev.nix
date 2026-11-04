{ inputs, ... }:

{
  flake.modules.nixos.dev = { pkgs, ... }:

    let
      claude-code = inputs.claude-code.packages.${pkgs.stdenv.hostPlatform.system}.claude-code;
      nub = inputs.nub.packages.${pkgs.stdenv.hostPlatform.system}.nub;
    in

    {
      nix.settings = {
        substituters = [ "https://claude-code.cachix.org" ];
        trusted-substituters = [ "https://claude-code.cachix.org" ];
        trusted-public-keys = [ "claude-code.cachix.org-1:YeXf2aNu7UTX8Vwrze0za1WEDS+4DuI2kVeWEE4fsRk=" ];
      };

      environment.systemPackages = with pkgs; [
        atlas
        android-tools
        binutils
        unstable.bun
        chezmoi
        claude-code
        cmake
        direnv
        gcc
        gdb
        git
        gnumake
        go
        lua
        pnpm
        nodejs
        nub
        unstable.opencode
        openssl
        overmind
        unstable.neovim
        postgresql
        python3
        rustup
        smartmontools
        tree-sitter
        uv
        vscode
        yaak
        zellij

        # FHS software
        (let base = appimageTools.defaultFhsEnvArgs; in
          buildFHSEnv ( base // {
            name = "fhs";
            targetPkgs = pkgs:
              (base.targetPkgs pkgs) ++ (with pkgs; [
                # bambu-studio
                # orca-slicer
              ]);
            profile = "export FHS=1";
            runScript = "zsh";
            extraOutputsToInstall = ["dev"];
          })
        )
      ];
    };
}
