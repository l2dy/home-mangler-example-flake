{
  inputs = {
    systems.url = "github:nix-systems/default";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-mangler = {
      url = "github:l2dy/home-mangler";
      inputs.systems.follows = "systems";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self, systems, nixpkgs, nixpkgs-unstable, home-mangler, ... }@inputs:
    # Import packages from default.nix as output
    (import ./. inputs) // {
      home-mangler = {
        your-hostname = let
          pkgs = nixpkgs.legacyPackages.aarch64-linux;
          home-mangler-lib = home-mangler.lib.aarch64-linux;
          local-packages = self.packages.aarch64-linux;
        in home-mangler-lib.makeConfiguration {
          packages = [
            # Base
            local-packages.home-mangler

            # Nix Tools
            pkgs.nixfmt
            pkgs.nix-melt
            pkgs.nix-tree

            # Editors
            local-packages.emacs-nox
            pkgs.helix

            # Development
            local-packages.flyctl
            local-packages.erlang
            local-packages.elixir
            local-packages.elixir-ls
            pkgs.bpf-linker
            pkgs.nodejs
            pkgs.pahole
            pkgs.phpactor
            pkgs.sqlite

            # Utilities
            pkgs.chezmoi
            pkgs.croc
            pkgs.diff-so-fancy
            pkgs.eza
            pkgs.starship
            pkgs.zellij
            pkgs.zoxide
          ];
        };
      };
    };
}
