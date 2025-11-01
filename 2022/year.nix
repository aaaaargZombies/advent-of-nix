{ lib, ... }:
let
  utils = import ../utils.nix { inherit lib; };
in
./.
|> builtins.readDir
|> lib.filterAttrs (name: _: utils.string.startsWith "day" name)
|> builtins.mapAttrs (n: _v: ./. + "/${n}")
|> builtins.mapAttrs (_n: path: utils.makeDayTest (import path { inherit lib; }))
