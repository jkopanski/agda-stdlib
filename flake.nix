{
  description = "A standard library for use with the Agda compiler";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        agdaWithStandardLibrary = pkgs.agda.withPackages (p: []);

      in {
        devShell = pkgs.mkShell { buildInputs = [ pkgs.agdaWithStandardLibrary ]; };

        packages.default = pkgs.agdaPackages.mkDerivation rec {
          pname = "standard-library";
          version = "2.0.0";
          src = ./.;

          nativeBuildInputs = [ (pkgs.haskellPackages.ghcWithPackages (self : [ self.filemanip ])) ];

          preConfigure = ''
            runhaskell GenerateEverything.hs
            # We will only build/consider Everything.agda, in particular we don't want Everything*.agda
            # do be copied to the store.
            rm EverythingSafe.agda
          '';

          meta = with pkgs.lib; {
            homepage = "https://wiki.portal.chalmers.se/agda/pmwiki.php?n=Libraries.StandardLibrary";
            description = "A standard library for use with the Agda compiler";
            license = licenses.mit;
            platforms = platforms.unix;
            # Maintainers for the upstream nixpkgs package, which code I just copied
            maintainers = with maintainers; [ jwiegley mudri alexarice turion ];
          };
        };
      }
    );
}
