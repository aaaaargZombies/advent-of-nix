{ lib, ... }:
let
  utils = import ../utils.nix { inherit lib; };
  inherit (utils)
    string
    list
    tuple
    math
    set
    trace
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

  expect01 = 40;
  # expect02 = 40;
  # expectReal01 = 1579;
  # expectReal02 = 13418215871354;

  input = builtins.readFile ./input/day08.txt;

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

  closest10 =
    vecs:
    vecs
    |> list.combinations 2
    |> map (ps: tuple.pair (distance (list.at 0 ps) (list.at 1 ps)) ps)
    |> builtins.sort (a: b: a.left < b.left)
    |> map tuple.snd
    |> lib.take 10;

  add = set: vecStr: set // { ${vecStr} = 1; };

  lstToSet = vecs: vecs |> builtins.foldl' (set: v: add set (builtins.toJSON v)) { };

  mergeSets =
    xss:
    let
      len = builtins.length xss;
      head = lib.take 1 xss;
      tail = lib.drop 1 xss;
      merged = builtins.foldl' (
        acc: connection:
        let
          pair =
            builtins.foldl'
              (
                { acc_, added }:
                circ:
                if set.intersect circ connection then
                  {
                    acc_ = acc_ ++ [ (circ // connection) ];
                    added = true;
                  }

                else
                  {
                    acc_ = acc_ ++ [ circ ];
                    added = added;
                  }
              )
              {
                acc_ = [ ];
                added = false;
              }
              acc;
        in
        if pair.added then pair.acc_ else acc ++ [ connection ]
      ) head tail;
    in
    if builtins.length merged == len then merged else mergeSets merged;

  countCurcuits = sets: sets |> builtins.map (s: s |> builtins.attrValues |> list.sum);

  /*
        - find 10 shortest connections
    		- collect into circuits (connected vecs)
        - take 3 largest circuits
        - count the nodes in each circuit
        - times the circuit sizes together
  */

  part01 =
    input:
    input
    |> parseInput
    |> closest10
    |> builtins.map lstToSet
    |> mergeSets
    |> countCurcuits
    |> builtins.sort (a: b: a > b)
    |> lib.take 3
    |> builtins.foldl' (acc: n: acc * n) 1
    # |> trace "LAST PART"
		;

  part02 = input: input;

}
