{ lib, ... }:
rec {
  list = rec {
    sum = lib.fold (a: b: a + b) 0;
    fold_ = f: lst: lib.fold f (at 0 lst) (lib.drop 1 lst);
    max = fold_ (a: b: lib.max a b);
    min = fold_ (a: b: lib.min a b);
    at = n: lst: builtins.elemAt lst n;
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

  string = {
    lines = str: str |> lib.trim |> lib.splitString "\n";
    chunks = str: str |> lib.trim |> lib.splitString "\n\n";
  };

}
