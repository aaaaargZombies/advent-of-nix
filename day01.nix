{ lib, ... }:
rec {
  expect01 = 24000;

  testInput = ''
    1000
    2000
    3000

    4000

    5000
    6000

    7000
    8000
    9000

    10000'';

  input = builtins.readFile ./input/day01.txt;

  part00 =
    input:
    input
    |> lib.splitString "\n\n"
    |> map (lib.splitString "\n")
    |> map (map (str: if str == "" then 0 else lib.toInt str))
    |> map (lib.fold (a: b: a + b) 0);

  part01 = input: input |> part00 |> lib.fold lib.max 0;

  part02 =
    input: input |> part00 |> builtins.sort (a: b: a > b) |> lib.take 3 |> (lib.fold (a: b: a + b) 0);

}
