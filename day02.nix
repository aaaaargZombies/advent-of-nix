{ lib, ... }:
rec {
  expect = 15;

  testInput = ''
    		A Y
        B X
        C Z
  '';

  input = builtins.readFile ./input/day02.txt;

  decode =
      {
        A = "Rock";
        B = "Paper";
        C = "Scissors";
        Y = "Rock";
        X = "Paper";
        Z = "Scissors";
      };

  # gameToScore = a: b: decode a + decode b ;
  gameToScore = a: b: decode.${a} + decode.${b} ;

  # this is not a doc string?
  part01 =
    input:
    input
    |> lib.trim
    |> lib.splitString "\n"
    |> map lib.trim
    |> map (lib.splitString " ")
    # |> map (builtins.stringLength)
    |> map (game: gameToScore (builtins.elemAt game 0) (builtins.elemAt game 1))
  # |> map (map (str: if str == "" then 0 else lib.toInt str))
  # |> map (lib.fold (a: b: a + b) 0)
  ;

}
