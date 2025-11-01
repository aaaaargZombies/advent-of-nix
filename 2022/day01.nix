{ lib, ... }:
let
  utils = import ../utils.nix { inherit lib; };
  inherit (utils) list string;
in
rec {

  sampleInput = ''
    1000
    2000
    3000

    4000

    5000
    6000

    7000
    8000
    9000

    10000'';

  input = builtins.readFile ./input/day01.txt;

  part00 =
    input:
    input
    |> string.chunks
    |> map string.lines
    |> map (map (str: if str == "" then 0 else lib.toInt str))
    |> map list.sum;

  part01 = input: input |> part00 |> list.max;

  part02 = input: input |> part00 |> builtins.sort (a: b: a > b) |> lib.take 3 |> list.sum;

  testPart1 = {
    expr = part01 sampleInput;
    expected = 24000;
  };

  testPart2 = {
    expr = part02 sampleInput;
    expected = 45000;
  };

  testRealPart1 = {
    expr = part01 input;
    expected = 69177;
  };
  testRealPart2 = {
    expr = part02 input;
    expected = 207456;
  };

}
