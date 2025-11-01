{ lib, ... }:
rec {
  list = rec {
    sum = builtins.foldl' (a: b: a + b) 0;
    fold_ = f: lst: builtins.foldl' f (at 0 lst) (lib.drop 1 lst);
    max = fold_ (a: b: lib.max a b);
    min = fold_ (a: b: lib.min a b);
    at = f.flip builtins.elemAt;
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

  makeDayTest =
    {
      sampleInput ? "",
      input ? "",
      expect01 ? "",
      part01 ? (a: a),
      expect02 ? "",
      part02 ? (a: a),
      expectReal01 ? "",
      expectReal02 ? "",
      ...
    }:
    {
      testPart01 = {
        expr = part01 sampleInput;
        expected = expect01;
      };

      testPart02 = {
        expr = part02 sampleInput;
        expected = expect02;
      };

      testPartReal01 = {
        expr = part01 input;
        expected = expectReal01;
      };
      testPartReal02 = {
        expr = part02 input;
        expected = expectReal02;
      };

    };

}
