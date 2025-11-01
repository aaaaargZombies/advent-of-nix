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

  expect01 = 24000;
  expect02 = 45000;
  expectReal01 = 69177;
  expectReal02 = 207456;

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

}
