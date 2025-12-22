{ lib, ... }:
let
  utils = import ../utils.nix { inherit lib; };
  inherit (utils)
    trace
    string
    list
    tuple
    ;
in
rec {

  sampleInput = ''
    0:
    ###
    ##.
    ##.

    1:
    ###
    ##.
    .##

    2:
    .##
    ###
    ##.

    3:
    ##.
    ###
    ##.

    4:
    ###
    #..
    ###

    5:
    ###
    .#.
    ###

    4x4: 0 0 0 0 2 0
    12x5: 1 0 1 0 2 2
    12x5: 1 0 1 0 3 2
  '';

  expect01 = 2;
  # expect02 = 2;
  # expectReal01 = 786;
  # expectReal02 = 169709990062889;

  input = builtins.readFile ./input/day12.txt;

  parseInput = str: str;

  part01 = input: input |> parseInput;

  part02 = input: input |> parseInput;

}
