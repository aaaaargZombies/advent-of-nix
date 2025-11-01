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
  priority =
    char:
    let
      n = lib.strings.charToInt;
      score =
        if n > 96 then
          n - 96
        else if n > 64 then
          n - 38
        else
          0;
    in
    score;

  halves =
    str:
    let
      length = builtins.stringLength str;
      mid = length / 2;
      l = builtins.substring 0 mid str;
      r = builtins.substring mid length str;
    in
    [
      l
      r
    ];

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

  # input = builtins.readFile ./input/day03.txt;

  part01 = input: input |> string.lines |> map halves |> utils.trace "HERE 🦄🦄🦄🦄🦄🦄🦄🦄";

  part02 = input: input;

}
