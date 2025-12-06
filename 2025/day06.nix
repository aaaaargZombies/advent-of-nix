{ lib, ... }:
let
  utils = import ../utils.nix { inherit lib; };
  inherit (utils) string list tuple;
in
rec {

  sampleInput = ''
    123 328  51 64 
     45 64  387 23 
      6 98  215 314
    *   +   *   +  
  '';

  rotate =
    xss:
    let
      width = builtins.length (builtins.elemAt xss 0);
      collumns = builtins.genList (a: [ ]) width;
    in
    builtins.foldl' (acc: row: list.map2 (col: el: col ++ [ el ]) acc row) collumns xss;

  expect01 = 4277556;
  expect02 = 3263827;
  expectReal01 = 5873191732773;
  expectReal02 = 11386445308378;

  input = builtins.readFile ./input/day06.txt;

  actions = {
    "+" = {
      f = a: b: a + b;
      noOp = 0;
    };
    "*" = {
      f = a: b: a * b;
      noOp = 1;
    };
  };

  parseInput =
    str:
    str
    |> string.lines
    |> (
      xs:
      let
        len = builtins.length xs;
        actions' =
          list.at (len - 1) xs
          |> lib.splitString " "
          |> builtins.filter (a: a != "")
          |> map (a: actions.${a});
        ns =
          lib.take (len - 1) xs
          |> map (s: s |> lib.splitString " " |> builtins.filter (a: a != ""))
          |> map (map lib.toIntBase10);
      in
      tuple.pair actions' ns
    );
  /*
    ["*","+","*","+"]
    [
    [123,328,51,64],
    [45,64,387,23],
    [6,98,215,314]]
  */
  performActions =
    actions': rows:
    let
      acc = map (a: a.noOp) actions';
      len = builtins.length actions';
    in
    builtins.foldl' (
      acc: row:
      builtins.genList (
        n:
        let
          act = list.at n actions';
          prev = list.at n acc;
          el = list.at n row;
        in
        act.f prev el
      ) len
    ) acc rows;

  part01 = input: input |> parseInput |> ({ left, right }: performActions left right) |> list.sum;

  parseToColumns =
    str:
    str
    |> string.lines
    |> (
      xs:
      let
        len = builtins.length xs;
        actions' =
          list.at (len - 1) xs
          |> lib.splitString " "
          |> builtins.filter (a: a != "")
          |> map (a: actions.${a});
        ns =
          lib.take (len - 1) xs
          |> map lib.stringToCharacters
          |> rotate
          |> map (builtins.filter (a: a != " "))
          |> map (lib.join "")
          |> (lib.join "\n")
          |> string.chunks
          |> map string.lines
          |> map (map lib.toIntBase10);
      in
      tuple.pair actions' ns
    );

  /*
    [ "*"       ,"+"        ,"*"         ,"+"        ]
    [ [1,24,356],[369,248,8],[32,581,175],[623,431,4]]
  */

  part02 =
    input:
    input
    |> parseToColumns
    |> (
      { left, right }:
      list.map2 tuple.pair left right
      |> builtins.foldl' (
        acc: actCol: (builtins.foldl' (acc': n: actCol.left.f acc' n) actCol.left.noOp actCol.right) + acc
      ) 0
    );

}
