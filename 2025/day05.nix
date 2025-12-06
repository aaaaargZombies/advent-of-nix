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
  # expect02 = 1553;
  # expectReal01 = 43;
  # expectReal02 = 8442;

  input = builtins.readFile ./input/day05.txt;

  ranges = str: str |> string.lines |> map (lib.splitString "-") |> map (map lib.toIntBase10) |> map tuple.fromList ;

	ingredients = str: str |> string.lines |> map lib.toIntBase10;

  parseInput = str: str |> string.chunks |> tuple.fromList |> tuple.mapBoth ranges ingredients ;

	inRange = n: {left,right}: n >= left && n <= right;

	inAnyRange = n: xs: builtins.any (inRange n) xs;

  part01 = input: input |> parseInput |> ({left, right}: builtins.foldl' (acc: el: if inAnyRange el left then acc + 1 else acc  ) 0 right);



  part02 = input: input |> parseInput |> tuple.fst |> builtins.concatMap ({left, right}: lib.range left right) |> lib.unique |> lib.length;

}
