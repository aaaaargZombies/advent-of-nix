{ lib, ... }:
let
  utils = import ../utils.nix { inherit lib; };
  inherit (utils)
    math
    string
    list
    tuple
    trace
    ;
in
rec {

  sampleInput = ''
    [.##.] (3) (1,3) (2) (2,3) (0,2) (0,1) {3,5,4,7}
    [...#.] (0,2,3,4) (2,3) (0,4) (0,1,2) (1,2,3,4) {7,5,12,7,2}
    [.###.#] (0,1,2,3,4) (0,3,4) (0,1,2,4,5) (1,2) {10,11,11,5,10,5}
  '';

  # expect01 = 3;
  # expect02 = 6;
  # expectReal01 = 989;
  # expectReal02 = 5941;
  #
  # input = builtins.readFile ./input/day10.txt;

  toggleLight = char: if char == "#" then "." else "#";

  toggleLights =
    lights: idx:
    builtins.foldl' (
      { left, right }:
      char:
      if idx == right then
        tuple.pair (left ++ [ (toggleLight char) ]) (right + 1)
      else
        tuple.pair (left ++ [ char ]) (right + 1)
    ) (tuple.pair [ ] 0) lights
    |> tuple.fst;

  pressButton = light: button: builtins.foldl' toggleLights light button;

  toMachine =
    str:
    let
      parts = lib.splitString " " str;
      lights =
        parts
        |> list.at 0
        |> lib.stringToCharacters
        |> builtins.filter (
          c:
          !(builtins.elem c [
            "["
            "]"
          ])
        );
      joltage =
        lib.last parts
        |> lib.stringToCharacters
        |> builtins.filter (
          c:
          !(builtins.elem c [
            "{"
            ","
            "}"
          ])
        );
      buttons =
        parts
        |> lib.drop 1
        |> lib.dropEnd 1
        |> builtins.map (
          str:
          str
          |> lib.stringToCharacters
          |> builtins.filter (
            c:
            !(builtins.elem c [
              "("
              ","
              ")"
            ])
          )
        );

    in
    {
      inherit lights buttons joltage;
    };

  parseInput = str: str |> string.lines |> builtins.map toMachine;

  part01 = input: input |> parseInput;

  part02 = input: input;

}
