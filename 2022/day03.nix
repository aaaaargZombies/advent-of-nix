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
  expectReal01 = 7737;
  expectReal02 = 2697;

  input = builtins.readFile ./input/day03.txt;

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

  part00 =
    input:
    input |> map list.sharedElements |> map lib.unique |> lib.flatten |> map priority |> list.sum;

  part01 = input: input |> string.lines |> map halves |> map tuple.toList |> part00;

  part02 =
    input: input |> string.lines |> list.chunk 3 |> map (map lib.strings.stringToCharacters) |> part00;

}
