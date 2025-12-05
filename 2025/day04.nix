{ lib, ... }:
let
  utils = import ../utils.nix { inherit lib; };
  inherit (utils) string list tuple;
in
rec {

  sampleInput = ''
    ..@@.@@@@.
    @@@.@.@.@@
    @@@@@.@.@@
    @.@@@@..@.
    @@.@@@@.@@
    .@@@@@@@.@
    .@.@.@.@@@
    @.@@@.@@@@
    .@@@@@@@@.
    @.@.@@@.@.
  '';

  expect01 = 13;
  expect02 = 1553;
  expectReal01 = 43;
  expectReal02 = 8442;

  input = builtins.readFile ./input/day04.txt;

  vec = x: y: {
    x = x;
    y = y;
  };

  board = w: h: xs: {
    width = w;
    height = h;
    board = xs;
  };

  get =
    { x, y }:
    {
      width,
      height,
      board,
    }:
    let
      n = (y * height) + x;
    in
    list.at n board;

  outOfBounds = { x, y }: { height, width, ... }: x < 0 || x >= width || y < 0 || y >= height;

  update =
    { x, y }:
    a:
    {
      width,
      height,
      board,
    }@b:
    let
      n = (y * height) + x;
    in
    board |> lib.imap0 (idx: el: if idx == n then a else el) |> (b_: b // { board = b_; });

  add = v1: v2: vec (v1.x + v2.x) (v1.y + v2.y);

  # (vec -1 -1) (vec 0 -1) (vec 1 -1)
  # (vec -1 0)  (vec x y)  (vec 1 0)
  # (vec -1 1)  (vec 0 1)  (vec 1 1)
  deltas = [
    (vec (-1) (-1))
    (vec 0 (-1))
    (vec 1 (-1))
    (vec (-1) 0)
    (vec 1 0)
    (vec (-1) 1)
    (vec 0 1)
    (vec 1 1)
  ];

  toBoard =
    str:
    str
    |> string.lines
    |> map lib.trim
    |> map lib.stringToCharacters
    |> (
      a:
      let
        h = builtins.length a;
        w = builtins.length (list.at 0 a);
        xs = builtins.concatLists a;
      in
      board w h xs
    );

  isRoll = board: vec': if outOfBounds vec' board then false else (get vec' board) == "@";

  countSurroundingRolls =
    board: vec':
    deltas |> map (add vec') |> builtins.foldl' (acc: el: if isRoll board el then acc + 1 else acc) 0;

  safeRollsCount =
    {
      board,
      height,
      width,
    }@board':
    let
      xRange = lib.range 0 (width - 1);
      yRange = lib.range 0 (height - 1);
      vecs = builtins.concatMap (x: builtins.map (y: vec x y) yRange) xRange;
      heatMap = vecs |> builtins.filter (isRoll board') |> map (countSurroundingRolls board');
      count = heatMap |> builtins.filter (el: el < 4) |> builtins.length;
    in
    count;

  removeSafeRoll = board: vec: update vec "x" board;

  removeSafeRolls =
    board:
    let
      xRange = lib.range 0 (board.width - 1);
      yRange = lib.range 0 (board.height - 1);
      vecs = builtins.concatMap (x: builtins.map (y: vec x y) yRange) xRange;
    in
    doRemoveSafeRolls vecs 0 board;

  doRemoveSafeRolls =
    vecs: acc: board:
    let
      updatedBoard =
        vecs
        |> builtins.filter (isRoll board)
        |> builtins.filter (v: countSurroundingRolls board v < 4)
        |> builtins.foldl' removeSafeRoll board;
      count = updatedBoard.board |> builtins.foldl' (sum: el: if el == "x" then sum + 1 else sum) 0;
    in
    if count == acc then acc else doRemoveSafeRolls vecs count updatedBoard;

  part01 = input: input |> toBoard |> safeRollsCount;

  part02 = input: input |> toBoard |> removeSafeRolls;

}
