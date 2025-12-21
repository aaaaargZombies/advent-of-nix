{ lib, ... }:
let
  utils = import ../utils.nix { inherit lib; };
  inherit (utils)
    list
    math
    set
    bool
    string
    trace
    tuple
    ;
in
rec {

  sampleInput = ''
    7,1
    11,1
    11,7
    9,7
    9,5
    2,5
    2,3
    7,3
    	'';

  lazyAll =
    predicate: xss: lib.lists.foldr (acc: x: if acc && predicate x then true else false) true xss;

  expect01 = 50;
  expect02 = 24;
  expectReal01 = 4741451444;
  # expectReal02 = 5941;

  input = builtins.readFile ./input/day09.txt;

  area =
    a: b:
    let
      x = a.x - b.x |> math.abs |> (n: n + 1);
      y = a.y - b.y |> math.abs |> (n: n + 1);
    in
    x * y;

  toVec =
    str:
    str
    |> lib.splitString ","
    |> map lib.toIntBase10
    |> (xy: {
      x = list.at 0 xy;
      y = list.at 1 xy;
    });

  parseInput = str: str |> string.lines |> builtins.map toVec;

  part01 =
    input:
    input
    |> parseInput
    |> list.combinations 2
    |> builtins.map (
      pair:
      let
        a = list.at 0 pair;
        b = list.at 1 pair;
      in
      area a b
    )
    |> list.max;

  /*
                    ..............
                    .......#XXX#..
                    .......X...X..
                    ..#XXXX#...X..
                    ..X........X..
                    ..#XXXXXX#.X..
                    .........X.X..
                    .........#X#..
                    ..............

                		- biggest rect that fits in the outline.
                		- a guess but looks like 3 corners need to be in our vec list.

            	     FIX: 110178214 your answer is too low.
        					      458930826 your answer is too high

            			 That didn't work, so maybe I just plot all the points.

            			 - moving down I take the frist two cords. fill in safe zone in between.
            			 - I keep adding in safe zone as I move down
            			 - if I hit more cords I fiter by x pos overlap.
            			 - if both new cords are in the same x as last then it's the end.

    							 NOTE: had to look up to solution "ray casting" / point in polygon
  */

  # FIX: building the board is what is extremely slow
  #  it is 98219 long on it's y axis!
  #  I am checking everything in the square against the board which is duplicate work
  #  I should just run the board building check on the square and not build the board!?
  board =
    vecs:
    let
      width = vecs |> builtins.map (v: v.x) |> list.max |> (n: n + 1);
      height = vecs |> builtins.map (v: v.y) |> list.max |> (n: n + 1);
      edges_ = edges vecs;
      outline = edges_ |> builtins.map ({ left, right }: allIdx left right) |> lib.flatten;
    in
    builtins.genList (
      y:
      builtins.genList (
        x: lib.elem { inherit x y; } outline || dawnRay'd edges_ { inherit x y; }
        # x: lib.elem { inherit x y; } outline
      ) width
    ) height
  # |> builtins.map fill
  ;

  predicate =
    vecs: vec:
    let
      edges_ = edges vecs;
      outline = edges_ |> builtins.map ({ left, right }: allIdx left right) |> lib.flatten;
    in
    lib.elem vec outline || dawnRay'd edges_ vec;

  visualizeBoard =
    board:
    board
    |> builtins.map (builtins.map (b: if b then "🟢" else "⚪"))
    |> builtins.map (lib.join "")
    |> lib.join "-";

  edges =
    vecs:
    let
      head = lib.take 1 vecs;
      wrapped = vecs ++ head;
    in
    builtins.genList (idx: tuple.pair (list.at idx vecs) (list.at (idx + 1) wrapped)) (
      builtins.length vecs
    );

  # ray casting check inside shape check. (inline with an edge counts as inside for our purposes)
  dawnRay'd =
    edges: vec:
    builtins.foldl' (
      count:
      { left, right }:
      let
        # not below both points or above both points.
        correctXspace = vec.y < left.y != vec.y < right.y;
        # inCorrectXspace = ((vec.y  < left.y  && vec.y  < right.y ) || (vec.y  > left.y  && vec.y  > right.y ));
        # point is before intersection of edge, traveling from low to high horizontally
        # Does the order of the points matter? should left.x always be less than right.x?
        correctYspace =
          (vec.x)
          < (right.x - left.x) * (vec.y - left.y) / (if right.y - vec.y == 0 then 1 else right.y - vec.y)
          + left.x;
        # FIX: can't devide by zero
      in
      if correctXspace && correctYspace then count + 1 else count
    ) 0 edges
    |> math.isEven
    |> bool.not;

  sortedByArea =
    vecs:
    vecs
    |> list.combinations 2
    |> builtins.sort (
      a: b:
      let
        a1 = list.at 0 a;
        a2 = list.at 1 a;
        b1 = list.at 0 b;
        b2 = list.at 1 b;
        areaA = area a1 a2;
        areaB = area b1 b2;
      in
      areaA > areaB
    );

  allIdx =
    start: end:
    let
      xmin = lib.min start.x end.x;
      xmax = lib.max start.x end.x;
      ymin = lib.min start.y end.y;
      ymax = lib.max start.y end.y;
    in
    builtins.genList (
      y:
      builtins.genList (x: {
        x = x + xmin;
        y = y + ymin;
      }) (xmax - xmin + 1)
    ) (ymax - ymin + 1)
    |> lib.flatten;

  allIdxTrue =
    start: end: pred:
    let
      xmin = lib.min start.x end.x;
      xmax = lib.max start.x end.x;
      ymin = lib.min start.y end.y;
      ymax = lib.max start.y end.y;
      doAllIdxTrue =
        current:
        if current.x == xmax && current.y == ymax then
          pred current
        else if pred current then
          let
            next =
              if current.x == end.x then
                {
                  y = current.y + 1;
                  x = xmin;
                }
              else
                {
                  y = current.y;
                  x = current.x + 1;
                };
          in
          doAllIdxTrue next end pred
        else
          false;
    in
    doAllIdxTrue {
      x = xmin;
      y = ymin;
    };

  allIdxTrue' =
    start: end: pred:
    let
      toKey = { x, y }: "${builtins.toString x},${builtins.toString y}";
      xmin = lib.min start.x end.x;
      xmax = lib.max start.x end.x;
      ymin = lib.min start.y end.y;
      ymax = lib.max start.y end.y;
      minVec = {
        x = xmin;
        y = ymin;
      };
      good =
        builtins.genericClosure {
          startSet = [
            {
              key = toKey minVec;
              current = minVec;
              state = pred minVec;
            }
          ];
          operator =
            item:
            if !item.state then
              [ ]
            else if item.current.x == xmax && item.current.y == ymax then
              [ ]
            else
              let
                next =
                  if item.current.x == xmax then
                    {
                      y = item.current.y + 1;
                      x = xmin;
                    }
                  else
                    {
                      y = item.current.y;
                      x = item.current.x + 1;
                    };
              in
              [
                {
                  key = toKey next;
                  current = next;
                  state = pred next;
                }
              ];

        }
        |> lib.last
        |> (a: a.state);
    in
    good;

  fourCorners =
    vecA: vecB:
    let
      vecAB = {
        x = vecA.x;
        y = vecB.y;
      };
      vecBA = {
        x = vecB.x;
        y = vecA.y;
      };
    in
    [
      vecA
      vecAB
      vecB
      vecBA
    ];

  pick =
    pred: sortedPairs:
    if list.isEmpty sortedPairs then
      0
    else
      let
        fst = list.at 0 sortedPairs;
        a = trace "AAAAAAAA" <| list.at 0 fst;
        b = trace "BBBBBBBB" <| list.at 1 fst;
        # FIX: this is causing the crashout
        idxs = trace "ALL IDXS" <| allIdx a b;
        safe = idxs |> builtins.all pred;
        safe_ =
          fourCorners a b
          |> edges
          |> builtins.all ({ left, right }: allIdxTrue' left right pred)
          |> trace "IS SAFE";
        # NOTE: I only need to check the outline, like in the predicate function, I just need 4 edges of vecs, not the whole center.
        # this ran for 45mins without exploding the memory!!!! but it also ran for 45mins¡¡¡¡¡
        # safe_ = allIdxTrue' a b pred;
      in
      if safe_ then area a b else pick pred (lib.drop 1 sortedPairs);

  # only test corners
  # NOTE: even only testing corners at current rate it will take about 42 years to complete 😭
  pick' =
    pred: sortedPairs:
    if list.isEmpty sortedPairs then
      0
    else
      let
        fst = list.at 0 sortedPairs;
        a = trace "AAAAAAAA" <| list.at 0 fst;
        b = trace "BBBBBBBB" <| list.at 1 fst;
        # FIX: this is causing the crashout
        idxs = trace "ALL IDXS" <| allIdx a b;
        safe = idxs |> builtins.all pred;
        safe_ = fourCorners a b |> builtins.all pred |> trace "IS SAFE";
        # NOTE: I only need to check the outline, like in the predicate function, I just need 4 edges of vecs, not the whole center.
        # this ran for 45mins without exploding the memory!!!! but it also ran for 45mins¡¡¡¡¡
        # safe_ = allIdxTrue' a b pred;
      in
      if safe_ then area a b else pick pred (lib.drop 1 sortedPairs);

  part02 =
    input:
    input
    |> parseInput
    |> (
      vecs:
      let
        pairs = sortedByArea vecs;
        isSafe = predicate vecs;
      in
      pick' isSafe pairs
    );
}
