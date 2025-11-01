{ lib, ... }:
let
  utils = import ../utils.nix { inherit lib; };
in
rec {
  day01 = import ./day01.nix { inherit lib; };
  day02 = import ./day02.nix { inherit lib; };

  day_01 = utils.makeDayTest day01;
  day_02 = utils.makeDayTest day02;
}
