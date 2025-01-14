{ systems, nixpkgs, nixpkgs-unstable, home-mangler, ... }@inputs:
builtins.foldl' nixpkgs.lib.recursiveUpdate { } (builtins.map (system:
  let
    pkgs = import nixpkgs {
      inherit system;
      overlays = [ ];
    };
    pkgs-unstable = import nixpkgs-unstable {
      inherit system;
      overlays = [ ];
    };
    home-mangler-packages = home-mangler.packages.${system};

    # Import local packages from the nix/packages folder.
    # Only pass inputs explicitly for purity.
    #
    # Copied from https://github.com/home-mangler/home-mangler/blob/b0a1c97ceb28d5d94acc841ce60fec09251cc8fc/flake.nix#L36-L44.
    packages = pkgs.callPackage ./nix/makePackages.nix { inputs = { }; };

    # Function to build a custom emacs.
    emacsWithPackages =
      (pkgs.emacsPackagesFor pkgs.emacs-nox).emacsWithPackages;
  in {
    packages.${system} = rec {
      # Packages exported as is
      inherit (packages) flyctl;
      inherit (home-mangler-packages) home-mangler;

      # Erlang and Elixir tooling with specific versions
      erlang = pkgs.beam.interpreters.erlang_27;
      elixir = pkgs.beam.packages.erlang_27.elixir_1_18;
      # Use elixir-ls from unstable.
      elixir-ls = (pkgs-unstable.beam.packages.erlang_27.elixir-ls.override {
        inherit elixir;
      });

      # Emacs
      # Can be reverted to default emacs-nox package when https://github.com/doomemacs/doomemacs/issues/7623 is resolved.
      emacs-nox = (emacsWithPackages (epkgs:
        (with epkgs;
          [
            (treesit-grammars.with-grammars (p: [
              p.tree-sitter-bash
              p.tree-sitter-beancount
              p.tree-sitter-c
              p.tree-sitter-cpp
              p.tree-sitter-clojure
              p.tree-sitter-commonlisp
              p.tree-sitter-c-sharp
              p.tree-sitter-dart
              p.tree-sitter-elm
              p.tree-sitter-elisp
              p.tree-sitter-erlang
              p.tree-sitter-fortran
              p.tree-sitter-gdscript
              p.tree-sitter-go
              p.tree-sitter-gomod
              p.tree-sitter-gowork
              p.tree-sitter-graphql
              p.tree-sitter-haskell
              p.tree-sitter-json
              p.tree-sitter-jsonnet
              p.tree-sitter-java
              p.tree-sitter-javascript
              p.tree-sitter-typescript
              p.tree-sitter-julia
              p.tree-sitter-kotlin
              p.tree-sitter-latex
              p.tree-sitter-ledger
              p.tree-sitter-lua
              p.tree-sitter-fennel
              p.tree-sitter-markdown
              p.tree-sitter-markdown-inline
              p.tree-sitter-nix
              p.tree-sitter-ocaml
              p.tree-sitter-php
              p.tree-sitter-python
              p.tree-sitter-rst
              p.tree-sitter-ruby
              p.tree-sitter-rust
              p.tree-sitter-scala
              p.tree-sitter-scheme
              p.tree-sitter-solidity
              p.tree-sitter-typst
              p.tree-sitter-html
              p.tree-sitter-css
              p.tree-sitter-yaml
              p.tree-sitter-zig
            ]))
          ])));
    };
  }) (import systems))
