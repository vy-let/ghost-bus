{
  description = "How good's the bus, tho?";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }: let
    system = "aarch64-darwin";

  in {
    devShells."${system}".default = let
      pkgs = import nixpkgs { inherit system; };

    in pkgs.mkShell {
      packages = with pkgs; [
        # development
        fish
        ruby-lsp

        # runtime deps
        # TODO: move these out?
        ruby
        rubyPackages.sqlite3
        rubyPackages.activerecord
      ];

      shellHook = ''
        exec fish
      '';
    };

  };
}
