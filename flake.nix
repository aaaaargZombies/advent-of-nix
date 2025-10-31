{
  description = "Advent Of Code in Nix";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nix-unit.url = "github:nix-community/nix-unit";
    nix-unit.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      nix-unit,
      ...
    }:
    let
      lib = nixpkgs.lib;
      y2022 = {
        day01 = import ./2022/day01.nix { inherit lib; };
        day02 = import ./2022/day02.nix { inherit lib; };
      };
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {

      tests = y2022;

      formatter.${system} = pkgs.nixfmt-tree;

      packages.${system} = {
        show_ = pkgs.writeShellApplication {
          # create age public key for use with sops-nix
          name = "show";
          runtimeInputs = [
          ];
          text = ''
            					   echo ${toString (y2022.day02.part02 y2022.day02.problemInput)}
          '';
        };

      };

      checks.${system}.default =
        nixpkgs.legacyPackages.${system}.runCommand "tests"
          {
            nativeBuildInputs = [ nix-unit.packages.${system}.default ];
          }
          ''
                        export HOME="$(realpath .)"
                        # The nix derivation must be able to find all used inputs in the nix-store because it cannot download it during buildTime.
                        nix-unit --eval-store "$HOME" \
            						  --extra-experimental-features pipe-operators \
                          --extra-experimental-features flakes \
                          --override-input nixpkgs ${nixpkgs} \
                          --flake ${self}#tests
                        touch $out
          '';

    };

}
