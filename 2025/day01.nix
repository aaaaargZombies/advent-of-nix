{ lib, ... }:
let
  utils = import ../utils.nix { inherit lib; };
  inherit (utils) math string tuple;
in
rec {

  sampleInput = ''
    L68
        L30
        R48
        L5
        R60
        L55
        L1
        L99
        R14
        L82'';

  expect01 = 3;
  expect02 = 6;
  expectReal01 = 989;
  expectReal02 = 5941;

  input = builtins.readFile ./input/day01.txt;

  # NOTE: when I include this function in my fold it causes a stack overflow
  # I think it's because the external function is treated like a closure/thunk and
  # we build up a something that is a bit like -
  # rotate -5 (rotate 48 (rotate -30 (rotate -68 50)))
  # I think without the closure we have TCO?
  rotate = by: target: lib.mod (target + by + 100) 100;

  toNum = str: str |> builtins.replaceStrings [ "R" "L" ] [ "" "-" ] |> lib.strings.toIntBase10;

  part01 =
    input:
    input
    |> string.lines
    |> map toNum
    |> builtins.foldl' (
      { left, right }:
      x:
      let
        dial = math.mod (right + x) 100;
        count = if dial == 0 then left + 1 else left;
      in
      tuple.pair count dial
    ) (tuple.pair 0 50)
    |> tuple.fst;

  part02 =
    input:
    input
    |> string.lines
    |> map toNum
    |> builtins.foldl' (
      { left, right }:
      x:
      let
        dial = math.mod (right + x) 100;

        fullRotations = math.abs <| x / 100;

        offset = math.remainder 100 x;

        passesZero = if right != 0 && (right + offset < 0 || right + offset > 100) then 1 else 0;

        onZero = if dial == 0 then 1 else 0;

        count = left + passesZero + onZero + fullRotations;
      in
      tuple.pair count dial
    ) (tuple.pair 0 50)
    |> tuple.fst;

}
