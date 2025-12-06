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

  expect01 = 3;
  expect02 = 14;
  expectReal01 = 798;
  expectReal02 = 366181852921027;

  input = builtins.readFile ./input/day05.txt;

  ranges =
    str:
    str |> string.lines |> map (lib.splitString "-") |> map (map lib.toIntBase10) |> map tuple.fromList;

  ingredients = str: str |> string.lines |> map lib.toIntBase10;

  parseInput = str: str |> string.chunks |> tuple.fromList |> tuple.mapBoth ranges ingredients;

  inRange = n: { left, right }: n >= left && n <= right;

  inAnyRange = n: xs: builtins.any (inRange n) xs;

  part01 =
    input:
    input
    |> parseInput
    |> (
      { left, right }: builtins.foldl' (acc: el: if inAnyRange el left then acc + 1 else acc) 0 right
    );

  removeOverlap =
    ranges:
    ranges
    |> builtins.sort (a: b: a.left < b.left)
    |> (
      lst:
      let
        h = lib.take 1 lst;
        t = lib.drop 1 lst;
      in
      builtins.foldl' (
        acc: el:
        let
          h' = list.at 0 acc;
          t' = lib.drop 1 acc;
        in
        (removeOverlap_ h' el) ++ t'
      ) h t
    )
    |> map (a: 1 + a.right - a.left)
    |> list.sum;

  #removeOverlap_ :: Tuple Int Int -> Tuple Int Int -> [Tuple Int Int]
  removeOverlap_ =
    a: b:
    if b.left <= a.right then
      let
        r = lib.max a.right b.right;
      in
      [ (tuple.pair a.left r) ]
    else
      [
        b
        a
      ];
  # a.left == b.left -> return (a.left, largest.right)
  # a.left <= b.left && b.left < a.right -> return (a.left, largest.right)

  part02 = input: input |> parseInput |> tuple.fst |> removeOverlap;

}
