{ lib, ... }:
let
  utils = import ./utils.nix { inherit lib; };
  inherit (utils) set list string;
in
rec {
  expect = 15;

  testInput = ''
    		A Y
        B X
        C Z
  '';

  input = builtins.readFile ./input/day02.txt;

  decode = {
    A = "Rock";
    B = "Paper";
    C = "Scissors";
    X = "Rock";
    Y = "Paper";
    Z = "Scissors";
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

  outcome =
    oponenet: player:
    if player == oponenet then
      "Draw"
    else if beats.${player} == oponenet then
      "Won"
    else
      "Lose";

  gameToScore =
    a: b: (score.${outcome decode.${a} decode.${b}}) + (b |> set.getAttr decode |> (set.getAttr score));

  part01 =
    input:
    input
    |> string.lines
    |> map (lib.splitString " ")
    |> map (game: gameToScore (list.at 0 game) (list.at 1 game))
    |> list.sum;

}
