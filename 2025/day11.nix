{ lib, ... }:
let
  utils = import ../utils.nix { inherit lib; };
  inherit (utils)
    trace
    string
    list
    tuple
    ;
in
rec {

  sampleInput = ''
    aaa: you hhh
    you: bbb ccc
    bbb: ddd eee
    ccc: ddd eee fff
    ddd: ggg
    eee: out
    fff: out
    ggg: out
    hhh: ccc fff iii
    iii: out
  '';

  sampleInput' = ''
    svr: aaa bbb
    aaa: fft
    fft: ccc
    bbb: tty
    tty: ccc
    ccc: ddd eee
    ddd: hub
    hub: fff
    eee: dac
    dac: fff
    fff: ggg hhh
    ggg: out
    hhh: out
  '';

  expect01 = 5;
  expect02 = 2;
  expectReal01 = 786;
  # expectReal02 = 169709990062889;

  input = builtins.readFile ./input/day11.txt;

  lineToPair =
    str:
    let
      parts = lib.splitString ": " str;
      key = list.at 0 parts;
      connections = parts |> lib.last |> lib.splitString " ";
    in
    lib.nameValuePair key connections;

  pathsToOut =
    map:
    let
      init = {
        key = "you";
        next = "you";
      };
      paths = builtins.genericClosure {
        startSet = [ init ];
        operator =
          item:
          if item.next == "out" then
            [ ]

          else
            builtins.map (key: {
              key = key + item.key;
              next = key;
            }) map.${item.next};
      };
    in
    paths |> builtins.filter (item: item.next == "out") |> builtins.length;

  # FIX: runs out of memory
  #  maybe I am messing up by appending to the key, it means I never finnish a loop
  serverToOut =
    map:
    let
      init = {
        key = "svr";
        next = "svr";
        fft = false;
        dac = false;
        visited = [ ]; # NOTE: tried to exit early to save memory, pretty sure it used more memory lol
      };
      paths = builtins.genericClosure {
        startSet = [ init ];
        operator =
          item:
          if item.next == "out" || builtins.elem item.next item.visited then
            [ ]

          else
            builtins.map (key: {
              key = key + item.key;
              next = key;
              dac = item.dac || key == "dac";
              fft = item.fft || key == "fft";
              visited = [ item.next ] ++ item.visited;
            }) map.${item.next};
      };
    in
    paths |> builtins.filter (item: item.next == "out" && item.dac && item.fft) |> builtins.length;

  aToB =
    map: init: done:
    let
      paths = builtins.genericClosure {
        startSet = init;
        operator =
          item:
          if done item then
            [ ]

          else
            builtins.map (key: {
              key = key + item.key;
              next = key;
            }) map.${item.next};
      };
    in
    paths |> builtins.filter (done);

  # NOTE: attempt to discard the paths when we hit way points
  serverToOut' =
    map:
    let
      fftPaths = aToB map [
        {
          key = "svr";
          next = "svr";
        }
      ] (item: item.next == "fft");
      dacPaths = aToB map fftPaths (item: item.next == "dac");
      outPaths = aToB map dacPaths (item: item.next == "out");
    in
    outPaths |> builtins.length;

  parseInput = str: str |> string.lines |> builtins.map lineToPair |> builtins.listToAttrs;

  part01 = input: input |> parseInput |> pathsToOut;

  part02 = input: input |> parseInput |> serverToOut;

}
