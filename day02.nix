{ lib, ... }:
let
  utils = import ./utils.nix { inherit lib; };
  inherit (utils) set list string;
in
rec {
  expect01 = 15;
  expect02 = 12;

  testInput = ''
    		A Y
        B X
        C Z
  '';

  input = builtins.readFile ./input/day02.txt;

  decode01 = {
    A = "Rock";
    B = "Paper";
    C = "Scissors";
    X = "Rock";
    Y = "Paper";
    Z = "Scissors";
  };

  decode02 = {
    A = "Rock";
    B = "Paper";
    C = "Scissors";
    X = "Lose";
    Y = "Draw";
    Z = "Won";
  };

  score = {
    "Rock" = 1;
    "Paper" = 2;
    "Scissors" = 3;
    "Lose" = 0;
    "Draw" = 3;
    "Won" = 6;
  };

  beats = {
    "Rock" = "Scissors";
    "Paper" = "Rock";
    "Scissors" = "Paper";
  };

  loses = set.flip beats;

  toolChoice =
    oponent: goal:
    if goal == "Draw" then
      oponent
    else if goal == "Won" then
      loses.${oponent}
    else
      beats.${oponent};

  outcome =
    oponenet: player:
    if player == oponenet then
      "Draw"
    else if beats.${player} == oponenet then
      "Won"
    else
      "Lose";

  gameToScore01 =
    a: b:
    # outcome score
    (score.${outcome decode01.${a} decode01.${b}})
    # tool score
    + (b |> set.getAttr decode01 |> (set.getAttr score));

  gameToScore02 =
    a: b:
    # outcome score
    (b |> set.getAttr decode02 |> (set.getAttr score))
    # tool score
    + (score.${toolChoice decode02.${a} decode02.${b}});

  part01 =
    input:
    input
    |> string.lines
    |> map (s: s |> lib.trim |> lib.splitString " ")
    |> map (game: gameToScore01 (list.at 0 game) (list.at 1 game))
    |> list.sum;

  part02 =
    input:
    input
    |> string.lines
    |> map (s: s |> lib.trim |> lib.splitString " ")
    |> map (game: gameToScore02 (list.at 0 game) (list.at 1 game))
    |> list.sum;

}
