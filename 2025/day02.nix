{ lib, ... }:
let
  utils = import ../utils.nix { inherit lib; };
  inherit (utils) list tuple;
in
rec {

  sampleInput = ''
    11-22,95-115,998-1012,1188511880-1188511890,222220-222224,
    1698522-1698528,446443-446449,38593856-38593862,565653-565659,
    824824821-824824827,2121212118-2121212124
  '';

  expect01 = 1227775554;
  expect02 = 4174379265;
  expectReal01 = 56660955519;
  expectReal02 = 79183223243;

  input = builtins.readFile ./input/day02.txt;

  rangePair =
    str:
    str
    |> lib.splitString "-"
    |> tuple.fromList
    |> tuple.mapBoth lib.strings.toIntBase10 lib.strings.toIntBase10;

  range = { left, right }: lib.range left right;

  # if number is made up of repeated characters, eg 55 6464 123123
  numberRepeatsHalves =
    n:
    n
    |> toString
    |> (
      str:
      let
        length = builtins.stringLength str;
      in
      if lib.mod length 2 == 0 then
        let
          left = builtins.substring 0 (length / 2) str;
          right = builtins.substring (length / 2) length str;
        in
        left == right
      else
        false
    );

  numberRepeatsAny = n: n |> toString |> lib.stringToCharacters |> (chars : doElemsRepeat 1  (builtins.length chars) false chars) ;

  doElemsRepeat =
    subLength: listLength: acc: elems:
    if subLength > listLength / 2 then
      acc

    else
      let
        repeats = elems |> list.chunk' subLength |> list.homogenous;
      in
      if repeats then true else doElemsRepeat (subLength + 1) listLength acc elems;

  part01 =
    input:
    input
    |> lib.trim
    |> lib.splitString ","
    |> map rangePair
    |> builtins.concatMap range
    |> builtins.filter numberRepeatsHalves
    |> list.sum;

  # NOTE: horrendously slow 😎 76s!
  part02 =
    input:
    input
    |> lib.trim
    |> lib.splitString ","
    |> map rangePair
    |> builtins.concatMap range
    |> builtins.filter numberRepeatsAny
    |> list.sum;

}
