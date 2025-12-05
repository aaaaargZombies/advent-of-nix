{ lib, ... }:
let
  utils = import ../utils.nix { inherit lib; };
  inherit (utils) string list tuple;
in
rec {

  sampleInput = ''
3-5
10-14
16-20
12-18

1
5
8
11
17
32
  '';

  # expect01 = 13;
  # expect02 = 1553;
  # expectReal01 = 43;
  # expectReal02 = 8442;

  # input = builtins.readFile ./input/day05.txt;

  part01 = input: input;

  part02 = input: input;

}
