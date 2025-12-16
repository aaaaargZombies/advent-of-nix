{ lib, ... }:
let
  utils = import ../utils.nix { inherit lib; };
  inherit (utils)
    list
    math
    set
    string
    trace
    tuple
    ;
in
rec {

  sampleInput = ''
    			7,1
    11,1
    11,7
    9,7
    9,5
    2,5
    2,3
    7,3
    	'';

  expect01 = 50;
  # expect02 = 6;
  expectReal01 = 4741451444;
  # expectReal02 = 5941;

  input = builtins.readFile ./input/day09.txt;

  area =
    a: b:
    let
      x = a.x - b.x |> math.abs |> (n: n + 1);
      y = a.y - b.y |> math.abs |> (n: n + 1);
    in
    x * y;

  toVec =
    str:
    str
    |> lib.splitString ","
    |> map lib.toIntBase10
    |> (xy: {
      x = list.at 0 xy;
      y = list.at 1 xy;
    });

  parseInput = str: str |> string.lines |> builtins.map toVec;

  part01 =
    input:
    input
    |> parseInput
    |> list.combinations 2
    |> builtins.map (
      pair:
      let
        a = list.at 0 pair;
        b = list.at 1 pair;
      in
      area a b
    )
    |> list.max;

  part02 = input: input;

}
