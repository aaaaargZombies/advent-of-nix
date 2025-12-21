{ lib, ... }:
let
  utils = import ../utils.nix { inherit lib; };
  inherit (utils)
    math
    string
    list
    tuple
    trace
    ;
in
rec {

  sampleInput = ''
    [.##.] (3) (1,3) (2) (2,3) (0,2) (0,1) {3,5,4,7}
    [...#.] (0,2,3,4) (2,3) (0,4) (0,1,2) (1,2,3,4) {7,5,12,7,2}
    [.###.#] (0,1,2,3,4) (0,3,4) (0,1,2,4,5) (1,2) {10,11,11,5,10,5}
  '';

  expect01 = 7;
  # expect02 = 33;
  expectReal01 = 425;
  # expectReal02 = 5941;

  input = builtins.readFile ./input/day10.txt;

  lightsToString = lights: lights |> lib.join "";

  lightsInit = lights: lights |> builtins.map (_: ".");

  joltsToString = jolts: jolts |> builtins.map builtins.toString |> lib.join ",";

  joltsInit = jolts: jolts |> builtins.map (_: 0);

  findButtonSequenceLights =
    { lights, buttons, ... }:
    builtins.genericClosure {
      startSet = [
        {
          key = lights |> lightsInit |> lightsToString;
          path = [ ];
          state = lights |> lightsInit;
        }
      ];
      operator =
        item:
        if item.key == (lightsToString lights) then
          [ ]
        else
          builtins.map (
            button:
            let
              nextState = pressButtonLights item.state button;
            in
            {
              key = lightsToString nextState;
              path = item.path ++ [ button ];
              state = nextState;
            }
          ) buttons;
    }
    |> builtins.filter (item: item.key == lightsToString lights)
    |> list.at 0;

  # FIX: far too slow and memory hungry to by a usefull solution.
  findButtonSequenceJolts =
    { joltage, buttons, ... }:
    let
      goal = joltage |> joltsToString;
      tooFar =
        state: lib.zipListsWith (goal: current: goal < current) joltage state |> builtins.any (a: a);
    in
    builtins.genericClosure {
      startSet = [
        {
          key = joltage |> joltsInit |> joltsToString;
          path = [ ];
          state = joltage |> joltsInit;
        }
      ];
      operator =
        item:
        if item.key == goal || tooFar item.state then
          [ ]
        else
          builtins.map (
            button:
            let
              nextState = pressButtonJolts item.state button;
            in
            {
              key = joltsToString nextState;
              path = item.path ++ [ button ];
              state = nextState;
            }
          ) buttons;
    }
    |> builtins.filter (item: item.key == goal)
    |> list.at 0;

  toggleLight = char: if char == "#" then "." else "#";

  toggleLights =
    lights: idx:
    builtins.foldl' (
      { left, right }:
      char:
      if idx == right then
        tuple.pair (left ++ [ (toggleLight char) ]) (right + 1)
      else
        tuple.pair (left ++ [ char ]) (right + 1)
    ) (tuple.pair [ ] 0) lights
    |> tuple.fst;

  increaseJoltage =
    jolts: idx:
    builtins.foldl' (
      { left, right }:
      jolt:
      if idx == right then
        tuple.pair (left ++ [ (1 + jolt) ]) (right + 1)
      else
        tuple.pair (left ++ [ jolt ]) (right + 1)
    ) (tuple.pair [ ] 0) jolts
    |> tuple.fst;

  pressButtonLights = lights: button: builtins.foldl' toggleLights lights button;

  pressButtonJolts = jolts: button: builtins.foldl' increaseJoltage jolts button;

  toMachine =
    str:
    let
      parts = lib.splitString " " str;
      lights =
        parts
        |> list.at 0
        |> lib.stringToCharacters
        |> builtins.filter (
          c:
          !(builtins.elem c [
            "["
            "]"
          ])
        );
      joltage =
        lib.last parts
        |> builtins.replaceStrings [ "{" "}" ] [ "" "" ]
        |> lib.splitString ","
        |> builtins.map lib.toInt;
      buttons =
        parts
        |> lib.drop 1
        |> lib.dropEnd 1
        |> builtins.map (
          str:
          str
          |> lib.stringToCharacters
          |> builtins.filter (
            c:
            !(builtins.elem c [
              "("
              ","
              ")"
            ])
          )
          |> builtins.map lib.toInt
        );

    in
    {
      inherit lights buttons joltage;
    };

  parseInput = str: str |> string.lines |> builtins.map toMachine;

  part01 =
    input:
    input
    |> parseInput
    |> builtins.map findButtonSequenceLights
    |> builtins.map (item: item.path |> builtins.length)
    |> list.sum;

  part02 =
    input:
    input
    |> parseInput
    |> lib.drop 1
    |> lib.take 1
    |> builtins.map findButtonSequenceJolts
    |> builtins.map (item: item.path |> builtins.length)
    |> list.sum;

}
