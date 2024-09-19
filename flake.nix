{
  description = "Nix template for Effekt projects";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    effekt-nix = {
      url = "github:jiribenes/effekt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows ="flake-utils";
    };
  };

  outputs = { self, nixpkgs, flake-utils, effekt-nix }:
    # If you want only some specific systems, do the following instead:
    # flake-utils.lib.eachSystem ["aarch64-linux" "aarch64-darwin"] (system:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        effekt-lib = effekt-nix.lib.${system};

        # This project uses only the JS backend.
        backends = with effekt-lib.effektBackends; [ js ];

        # This project uses the latest released Effekt version.
        latestEffekt = effekt-nix.packages.${system}.default;

        # If you want, you can set a fixed Effekt version instead:
        #
        # effektVersion = "0.3.0";
        #
        # then replace `effekt = latestEffekt;` below (twice!) with `inherit effektVersion;`
      in {
        packages.default = effekt-lib.buildEffektPackage {
          pname = "effekt-stm";         # Package name
          version = "0.1.0";            # Package version
          src = ./.;                    # Source folder
          main = "stm.effekt";          # relative path to entrypoint (as a string)
          tests = [ "stm.effekt" ];     # relative paths to tests (as strings)

          effekt = latestEffekt;
          inherit backends;
        };

        devShells.default = effekt-lib.mkDevShell {
          effekt = latestEffekt;
          inherit backends;
        };
      }
    );
}
