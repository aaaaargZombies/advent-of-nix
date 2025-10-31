{ lib, ... }:
rec {
  list = {
    sum = lib.fold (a: b: a + b) 0;
  };

  f = {
    apply = a: f: f a;

    flip =
      f: a: b:
      f b a;
  };

  trace = str: a: builtins.trace "${str}: ${a}" a;

  set = {
    getAttr = f.flip builtins.getAttr;
  };

}
