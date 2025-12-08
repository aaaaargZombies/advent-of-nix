{ lib, ... }:
let
  utils = import ../utils.nix { inherit lib; };
  inherit (utils)
    string
    list
    tuple
    math
    ;
in
rec {

  sampleInput = ''
    162,817,812
    57,618,57
    906,360,560
    592,479,940
    352,342,300
    466,668,158
    542,29,236
    431,825,988
    739,650,466
    52,470,668
    216,146,977
    819,987,18
    117,168,530
    805,96,715
    346,949,466
    970,615,88
    941,993,340
    862,61,35
    984,92,344
    425,690,689
  '';

  # expect01 = 21;
  # expect02 = 40;
  # expectReal01 = 1579;
  # expectReal02 = 13418215871354;

  # input = builtins.readFile ./input/day08.txt;

  toVec =
    str:
    str
    |> lib.splitString ","
    |> map lib.toIntBase10
    |> (xyz: {
      x = list.at 0 xyz;
      y = list.at 1 xyz;
      z = list.at 2 xyz;
    });

  parseInput = str: str |> string.lines |> map toVec;

  distance =
    a: b:
    let
      x2 = math.square (b.x - a.x);
      y2 = math.square (b.y - a.y);
      z2 = math.square (b.z - a.z);
      sum = x2 + y2 + z2;
    in
    math.sqrt sum;

  part01 = input: input;

  part02 = input: input;

}
