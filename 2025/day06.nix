{ lib, ... }:
let
  utils = import ../utils.nix { inherit lib; };
  inherit (utils) string list tuple;
in
rec {

  sampleInput = ''
    123 328  51 64 
     45 64  387 23 
      6 98  215 314
    *   +   *   +  
  '';

  # expect01 = 3;
  # expect02 = 14;
  # expectReal01 = 798;
  # expectReal02 = 366181852921027;

  # input = builtins.readFile ./input/day05.txt;

  part01 = input: input;

  part02 = input: input;

}
