{ lib, ... }:
let
  utils = import ../utils.nix { inherit lib; };
  inherit (utils) string list tuple;
in
rec {

  sampleInput = ''
    987654321111111
    811111111111119
    234234234234278
    818181911112111
  '';

  expect01 = 357;
  expect02 = 3121910778619;
  expectReal01 = 17113;
  expectReal02 = 169709990062889;

  input = builtins.readFile ./input/day03.txt;

  tupleToInt = { left, right }: (left * 10) + right;

  largestTwo =
    nums:
    builtins.foldl' (
      { left, right }@acc:
      el:
      let
        a = {
          left = left;
          right = el;
        };
        b = {
          left = right;
          right = el;
        };
        biggest = builtins.foldl' (acc_: el: if (tupleToInt acc_) > (tupleToInt el) then acc_ else el) acc [
          a
          b
        ];
      in
      biggest
    ) (tuple.pair 0 0) nums;

  part01 =
    input:
    input
    |> string.lines
    |> map lib.stringToCharacters
    |> map (map lib.strings.toIntBase10)
    |> map largestTwo
    |> map tupleToInt
    |> list.sum;

  digitsToInt = ns: ns |> lib.concatMapStrings toString |> lib.strings.toIntBase10;

  greaterThanDigits =
    xs: ys:
    let
      xLen = builtins.length xs;
      yLen = builtins.length ys;
    in
    if xLen == yLen then
      if xLen == 0 && yLen == 0 then
        false
      else
        let
          x = list.at 0 xs;
          y = list.at 0 ys;
          xs_ = lib.drop 1 xs;
          ys_ = lib.drop 1 ys;
        in
        if x == y then greaterThanDigits xs_ ys_ else x > y
    else
      xLen > yLen;

  candidates =
    lst:
    let
      len = builtins.length lst;
      doCandidates =
        pos: acc:
        if pos < 1 then
          acc
        else
          let
            left = lib.take (pos - 1) lst;
            right = lib.drop (pos) lst;
            candidate = left ++ right;
          in
          doCandidates (pos - 1) ([ candidate ] ++ acc);
    in
    doCandidates len [ ];

  largestMinusOne =
    lst:
    lst |> candidates |> builtins.foldl' (acc: el: if greaterThanDigits el acc then el else acc) [ ];

  largestN = n: lst: if builtins.length lst <= n then lst else largestN n (largestMinusOne lst);

  part02 =
    input:
    input
    |> string.lines
    |> map lib.stringToCharacters
    |> map (map lib.strings.toIntBase10)
    |> map (largestN 12)
    |> map digitsToInt
    |> list.sum;

}
