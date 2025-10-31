{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
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
      formatter.${system} = pkgs.nixfmt-tree;

      packages.${system} = {
        show_ = pkgs.writeShellApplication {
          # create age public key for use with sops-nix
          name = "show";
          runtimeInputs = [
          ];
          text = ''
            					   echo ${toString (y2022.day02.part02 y2022.day02.input)}
          '';
        };

      };

      # --- The test ---
      # checks.${system}.hello-test =
      #   pkgs.runCommand "hello-test"
      #     {
      #     }
      #     ''
      #       output=${toString (day01.part01 day01.testInput)}
      #       if [ "$output" != ${toString day01.expect01} ]; then
      #         echo "Unexpected output: $output"
      #         exit 1
      #       fi
      #       echo "Test passed"
      #       touch $out
      #     '';

    };

}
