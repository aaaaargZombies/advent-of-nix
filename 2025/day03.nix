{ lib, ... }:
let
  utils = import ../utils.nix { inherit lib; };
  inherit (utils) string list tuple;
in
rec {

  sampleInput = ''
    987654321111111
    811111111111119
    234234234234278
    818181911112111
  '';

  expect01 = 357;
  # expect02 = 4174379265;
  expectReal01 = 17113;
  # expectReal02 = 79183223243;

  input = builtins.readFile ./input/day03.txt;

  tupleToInt = { left, right }: (left * 10) + right;

  largestTwo =
    nums:
    builtins.foldl' (
      { left, right }@acc:
      el:
      let
        a = {
          left = left;
          right = el;
        };
        b = {
          left = right;
          right = el;
        };
        biggest = builtins.foldl' (acc_: el: if (tupleToInt acc_) > (tupleToInt el) then acc_ else el) acc [
          a
          b
        ];
      in
      biggest
    ) (tuple.pair 0 0) nums;

  part01 =
    input:
    input
    |> string.lines
    |> map lib.stringToCharacters
    |> map (map lib.strings.toIntBase10)
    |> map largestTwo
    |> map tupleToInt
    |> list.sum;

  part02 = input: input;

}
