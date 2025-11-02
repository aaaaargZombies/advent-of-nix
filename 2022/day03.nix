{ lib, ... }:
let
  utils = import ../utils.nix { inherit lib; };
  inherit (utils)
    list
    string
    trace
    tuple
    ;
in
rec {

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

  /**
        nix-repl> "azAZ" |> lib.strings.stringToCharacters |> lib.map lib.strings.charToInt
        [
          97
          122
          65
          90
        ]

    		a == 1
    		z == 26
    		A == 27
    		Z == 52
  */
  priority =
    char:
    let
      n = lib.strings.charToInt char;
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
      l = str |> builtins.substring 0 mid |> lib.strings.stringToCharacters;
      r = str |> builtins.substring mid length |> lib.strings.stringToCharacters;
    in
    tuple.pair l r;

  sharedElements =
    { left, right }:
    left
    |> builtins.foldl' (acc: b: if builtins.elem b right then ([ b ] ++ acc) else acc) [ ]
    |> lib.unique;

  part01 =
    input:
    input
    |> string.lines
    |> map halves
    |> builtins.concatMap sharedElements
    |> map priority
    |> list.sum;

  part02 = input: input;

}
