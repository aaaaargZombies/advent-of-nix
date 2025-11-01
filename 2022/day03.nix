{ lib, ... }:
let
  utils = import ../utils.nix { inherit lib; };
  inherit (utils) list string;
in
rec {

  /**
    nix-repl> "azAZ" |> lib.strings.stringToCharacters |> lib.map lib.strings.charToInt
    [
      97
      122
      65
      90
    ]
  */

  sampleInput = ''
    vJrwpWtwJgWrhcsFMMfFFhFp
    jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL
    PmmdzqPrVvPwwTWBwg
    wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn
    ttgJtRGJQctTZtZT
    CrZsJsPPZsGzwwsLwLmpwMDw
  '';

  expect01 = 157;
  expect02 = 70;
  expectReal01 = 0;
  expectReal02 = 0;

  input = builtins.readFile ./input/day03.txt;

  part01 = input: input;

  part02 = input: input;

}
