{ lib, ... }:
rec {
  list = rec {
    sum = builtins.foldl' (a: b: a + b) 0;

    fold_ = f: lst: builtins.foldl' f (at 0 lst) (lib.drop 1 lst);

    max = fold_ (a: b: lib.max a b);

    min = fold_ (a: b: lib.min a b);

    at = f.flip builtins.elemAt;

    uncons = lst: tuple.pair (builtins.head lst) (lib.lists.drop 1 lst);

    foldl2 =
      f: acc: xs: ys:
      builtins.foldl' (
        { left, right }:
        x:
        let
          y = builtins.elemAt ys left;
        in
        tuple.pair (left + 1) (f right x y)
      ) (tuple.pair 0 acc) xs
      |> tuple.snd;

    map2 =
      f: xs: ys:
      foldl2 (
        acc: x: y:
        acc ++ [ (f x y) ]
      ) [ ] xs ys;
    /**
      		split a list into sublists, dropping any remainder
    */
    chunk =
      n: lst:
      let
        doChunk =
          acc: n: lst:
          if (builtins.length lst) < n then
            acc
          else
            let
              head = lib.lists.take n lst;
              tail = lib.lists.drop n lst;
            in
            doChunk (acc ++ [ head ]) n tail;
      in
      doChunk [ ] n lst;

    /**
      		split a list into sublists, retaining remainder in a shorter sublist
    */
    chunk' =
      n: lst:
      let
        doChunk =
          acc: n: lst:
          if (builtins.length lst) < n then
            if (builtins.length lst) > 0 then
              (acc ++ [ lst ]) # getting an empty list at the end of each
            else
              acc
          else
            let
              head = lib.lists.take n lst;
              tail = lib.lists.drop n lst;
            in
            doChunk (acc ++ [ head ]) n tail;
      in
      doChunk [ ] n lst;

    sharedElements =
      listOfLists:
      if builtins.length listOfLists < 2 then
        [ ]
      else
        let
          head = at 0 listOfLists;
          tail = lib.lists.drop 1 listOfLists;
        in
        builtins.foldl' (
          acc: el: if (builtins.all (lst: builtins.elem el lst) tail) then ([ el ] ++ acc) else acc
        ) [ ] head;

    /**
      		Are all elements equal?

      		# Examples

      		```nix
      		nix-repl> u.list.homogenous []
      		true

      		nix-repl> u.list.homogenous [1]
      		true

      		nix-repl> u.list.homogenous [1 1]
      		true

      		nix-repl> u.list.homogenous [1 2]
      		false
      		```
    */
    homogenous =
      lst:
      if builtins.length == 0 then
        true
      else
        builtins.foldl' (
          { left, right }: el: if left == false then tuple.pair false { } else tuple.pair (right == el) el
        ) (tuple.pair true (at 0 lst)) (lib.drop 1 lst)
        |> tuple.fst;
  };

  # combinators
  f = {
    apply = a: f: f a;

    flip =
      f: a: b:
      f b a;
  };

  trace = str: a: builtins.trace "${str}: ${builtins.toJSON a}" a;

  set = {
    getAttr = f.flip builtins.getAttr;

    flip =
      set: set |> builtins.attrNames |> lib.fold (name: acc: { ${set.${name}} = name; } // acc) { };
  };

  string = {
    lines = str: str |> lib.trim |> lib.splitString "\n";

    chunks = str: str |> lib.trim |> lib.splitString "\n\n";

    startsWith =
      sub: str:
      let
        to = builtins.stringLength sub;
        start = builtins.substring 0 to str;
      in
      sub == start;
  };

  tuple = {
    pair = l: r: {
      left = l;
      right = r;
    };

    fst = { left, right }: left;

    snd = { left, right }: right;

    mapLeft =
      f:
      { left, right }:
      {
        left = f left;
        right = right;
      };

    mapRight =
      f:
      { left, right }:
      {
        left = left;
        right = f right;
      };

    mapBoth =
      fLeft: fRight:
      { left, right }:
      {
        left = fLeft left;
        right = fRight right;
      };

    fromList = lst: tuple.pair (list.at 0 lst) (list.at 1 lst);

    toList =
      { left, right }:
      [
        left
        right
      ];

  };

  tripple = rec {
    triplet = l: m: r: {
      left = l;
      mid = m;
      right = r;
    };

    fromList = lst: triplet (list.at 0 lst) (list.at 1 lst) (list.at 2 lst);

    toList =
      {
        left,
        mid,
        right,
      }:
      [
        left
        mid
        right
      ];
  };

  math = {
    abs = n: if n >= 0 then n else (-n);

    remainder =
      div: n:
      let
        fits = n / div;
        takes = div * fits;
        remains = n - takes;
      in
      remains;

    mod = b: n: lib.mod b n |> (x: if x < 0 then x + n else x);
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
