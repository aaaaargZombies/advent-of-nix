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
      # y2022 = import ./2022/year.nix { inherit lib; };
      y2025 = import ./2025/year.nix { inherit lib; };

      day04 = import ./2025/day04.nix { inherit lib; };

      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {

      tests = y2025;

      formatter.${system} = pkgs.nixfmt-tree;

      packages.${system} = {
        show_ = pkgs.writeShellApplication {
          # create age public key for use with sops-nix
          name = "show";
          runtimeInputs = [ ];
          text = ''
            echo ${toString (day04.part02 day04.input)} 
          '';
        };

      };

      checks.${system}.default =
        pkgs.runCommand "tests"
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
