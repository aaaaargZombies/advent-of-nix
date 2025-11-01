{ lib, ... }:
{
  day01 = import ./day01.nix { inherit lib; };
  day02 = import ./day02.nix { inherit lib; };

  # TODO: make a function that takes a day set and makes tests
}
