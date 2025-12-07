{ lib, ... }:
let
  utils = import ../utils.nix { inherit lib; };
  inherit (utils) string list tuple;
in
rec {

  sampleInput = ''
    .......S.......
    ...............
    .......^.......
    ...............
    ......^.^......
    ...............
    .....^.^.^.....
    ...............
    ....^.^...^....
    ...............
    ...^.^...^.^...
    ...............
    ..^...^.....^..
    ...............
    .^.^.^.^.^...^.
    ...............
  '';

  expect01 = 21;
  expect02 = 40;
  expectReal01 = 1579;
  expectReal02 = 13418215871354;

  input = builtins.readFile ./input/day07.txt;

  parseInput =
    str:
    str
    |> string.lines
    |> map (lib.stringToCharacters)
    |> (
      xs:
      let
        laserIdx =
          xs
          |> list.at 0
          |> builtins.foldl' (
            { left, right }@acc:
            el:
            if left then
              acc

            else if el == "S" then
              {
                left = true;
                right = right;
              }
            else
              {
                left = left;
                right = right + 1;
              }
          ) (tuple.pair false 0)
          |> tuple.snd
          |> (a: [ a ]);
        manifold = lib.drop 1 xs;
      in
      tuple.pair laserIdx manifold
    );

  splitterContacts =
    laserIdxs: rows:
    builtins.foldl' (
      {
        left, # current laser positions
        right, # how many splitters we have encountered
      }:
      row:
      builtins.foldl' (
        { left, right }:
        idx:
        if list.at idx row == "^" then
          tuple.pair (
            left
            ++ [
              (idx - 1)
              (idx + 1)
            ]
            |> lib.unique
          ) (right + 1)
        else
          tuple.pair (left ++ [ idx ]) (right)
      ) (tuple.pair [ ] right) left
    ) (tuple.pair laserIdxs 0) rows
    |> tuple.snd;

  updateIdx =
    idx: count: idxs:
    if builtins.any ({ left, right }: left == idx) idxs then
      builtins.map (
        { left, right }@pair: if left == idx then tuple.pair left (right + count) else pair
      ) idxs
    else
      [ (tuple.pair idx count) ] ++ idxs;

  removeIdx = idx: map: builtins.filter ({ left, right }: left != idx) map;

  /**
    .......S.......    .......1....... == 1
    .......|.......    .......|.......
    ......|^|......    ......1^1...... == 2
    ......|.|......    ......|.|......
    .....|^|^|.....    .....1^2^1..... == 4
    .....|.|.|.....    .....|.|.|.....
    ....|^|^|^|....    ....1^3^3^1.... == 8
    ....|.|.|.|....    ....|.|.|.|...
    ...|^|^|||^|...    ...1^4^331^1... == 13
    ...|.|.|||.|...    etc
    ..|^|^|||^|^|..
    ..|.|.|||.|.|..
    .|^|||^||.||^|.
    .|.|||.||.||.|.
    |^|^|^|^|^|||^|
    |.|.|.|.|.|||.|
  */

  timelineCount =
    laserIdxs: rows:
    let
      routeStarts = builtins.foldl' (idxs: idx: updateIdx idx 1 idxs) [ ] laserIdxs; # this should probably just be a list of tuples
    in
    rows
    |> builtins.filter (xs: xs |> builtins.any (x: x == "^"))
    |> builtins.foldl' (
      routeCounts: # position and converging routes
      row:
      builtins.foldl' (
        routeCount':
        {
          left, # idx
          right, # routCount
        }:
        if list.at left row == "^" then
          routeCount' |> updateIdx (left - 1) right |> updateIdx (left + 1) right |> removeIdx left

        else
          routeCount'

      ) routeCounts routeCounts # functional updating faff
    ) routeStarts
    |> builtins.map tuple.snd
    |> list.sum;

  part01 = input: input |> parseInput |> ({ left, right }: splitterContacts left right);

  part02 = input: input |> parseInput |> ({ left, right }: timelineCount left right);

}
