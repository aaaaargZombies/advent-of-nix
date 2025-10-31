{ lib, ... }:
rec {
  list = rec {
    sum = lib.fold (a: b: a + b) 0;
    fold_ = f: lst: lib.fold f (at 0 lst) (lib.drop 1 lst);
    max = fold_ (a: b: lib.max a b);
    min = fold_ (a: b: lib.min a b);
    at =  f.flip builtins.elemAt;
  };

  # combinators
  f = {
    apply = a: f: f a;
    flip =
      f: a: b:
      f b a;
  };

  trace = str: a: builtins.trace "${str}: ${builtins.toString a}" a;

  set = {
    getAttr = f.flip builtins.getAttr;
    flip =
      set: set |> builtins.attrNames |> lib.fold (name: acc: { ${set.${name}} = name; } // acc) { };
  };

  string = {
    lines = str: str |> lib.trim |> lib.splitString "\n";
    chunks = str: str |> lib.trim |> lib.splitString "\n\n";
  };

}
