{
  # Language servers and formatters
  flake.modules.nixos.lsp = { pkgs, lib, ... }: {
    environment.systemPackages = with pkgs; [
      bash-language-server
      clang-tools
      docker-compose-language-service
      emmet-language-server
      intelephense
      jdt-language-server
      ltex-ls
      lua-language-server
      nil
      openscad-lsp
      prettierd
      pyright
      (lib.hiPrio rust-analyzer-unwrapped)
      stylua
      tailwindcss-language-server
      taplo
      typescript-language-server
      typescript
      yaml-language-server
      yamlfmt
      zls
    ];
  };
}
