{ lib, ... }:
let
  utils = import ../utils.nix { inherit lib; };
  inherit (utils) string list tuple;
in
rec {

  sampleInput = ''
    aaa: you hhh
    you: bbb ccc
    bbb: ddd eee
    ccc: ddd eee fff
    ddd: ggg
    eee: out
    fff: out
    ggg: out
    hhh: ccc fff iii
    iii: out
  '';

  expect01 = 5;
  # expect02 = 3121910778619;
  # expectReal01 = 17113;
  # expectReal02 = 169709990062889;

  input = builtins.readFile ./input/day11.txt;

  lineToPair =
    str:
    let
      parts = lib.splitString ": " str;
      key = list.at 0 parts;
      connections = parts |> lib.last |> lib.splitString " ";
    in
    lib.nameValuePair key connections;

  parseInput = str: str |> string.lines |> builtins.map lineToPair |> builtins.listToAttrs;

  part01 = input: input;

  part02 = input: input;

}
