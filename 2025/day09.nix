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

  expect01 = 50;
  # expect02 = 6;
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

    	     FIX: 110178214 That's not the right answer; your answer is too low.

    			 That didn't work, so maybe I just plot all the points.

    			 - moving down I take the frist two cords. fill in safe zone in between.
    			 - I keep adding in safe zone as I move down
    			 - if I hit more cords I fiter by x pos overlap.
    			 - if both new cords are in the same x as last then it's the end.
  */

  board =
    vecs:
    let
      width = vecs |> builtins.map (v: v.x) |> list.max |> (n: n + 1);
      height = vecs |> builtins.map (v: v.y) |> list.max |> (n: n + 1);
      edges_ = edges vecs;
    in
    builtins.genList (
      y:
      builtins.genList (
        x:
        #NOTE: do stuff in here, how to keep state about last area we fill in?

        # if lib.elem { inherit x y; } vecs then
        #   "🔴"
        # else 
				if dawnRay'd edges_ (trace "VEC" { inherit x y; }) then
          "🟢"
        else
          "⚪"

        /*
              ⚪⚪⚪⚪⚪⚪⚪⚪⚪⚪⚪⚪
              ⚪⚪⚪⚪⚪⚪⚪🟢⚪⚪⚪🟢
              ⚪⚪⚪⚪⚪⚪⚪⚪⚪⚪⚪⚪
              ⚪⚪🟢⚪⚪⚪⚪🟢⚪⚪⚪⚪
              ⚪⚪⚪⚪⚪⚪⚪⚪⚪⚪⚪⚪
              ⚪⚪🟢⚪⚪⚪⚪⚪⚪🟢⚪⚪
              ⚪⚪⚪⚪⚪⚪⚪⚪⚪⚪⚪⚪
              ⚪⚪⚪⚪⚪⚪⚪⚪⚪🟢⚪🟢

              ⚪⚪⚪⚪⚪⚪⚪⚪⚪⚪⚪⚪
              🟢🟢🟢🟢🟢🟢🟢🔴⚪⚪⚪🔴
              ⚪⚪⚪⚪⚪⚪⚪🟢🟢🟢🟢⚪
              ⚪⚪🔴🟢🟢🟢🟢🔴🟢🟢🟢⚪
              ⚪⚪🟢🟢🟢🟢🟢🟢🟢🟢🟢⚪
              ⚪⚪🔴⚪⚪⚪⚪⚪⚪🔴🟢⚪
              ⚪⚪⚪⚪⚪⚪⚪⚪⚪🟢🟢⚪
              🟢🟢🟢🟢🟢🟢🟢🟢🟢🔴🟢🔴

							🟢🟢🟢⚪⚪⚪⚪⚪⚪⚪🟢🟢
              ⚪⚪⚪🟢🟢🟢🟢🔴🟢🟢⚪🔴
              ⚪⚪⚪⚪⚪⚪⚪⚪⚪⚪🟢🟢
              ⚪⚪🔴⚪⚪⚪⚪🔴⚪⚪🟢🟢
              ⚪⚪⚪⚪⚪⚪⚪⚪🟢🟢🟢🟢
              ⚪⚪🔴⚪⚪⚪⚪⚪🟢🔴🟢🟢
              🟢🟢🟢⚪⚪⚪⚪⚪🟢🟢🟢🟢
              ⚪⚪⚪🟢🟢🟢🟢🟢⚪🔴⚪🔴


              ⚪⚪⚪⚪⚪⚪⚪⚪⚪⚪⚪⚪⚪
              🟢🟢🟢🟢🟢🟢🟢🔴🟢🟢🟢🔴⚪
              ⚪⚪⚪⚪⚪⚪⚪⚪🟢🟢🟢🟢⚪
              ⚪⚪🔴⚪⚪⚪⚪🔴🟢🟢🟢🟢⚪
              ⚪⚪⚪🟢🟢🟢🟢🟢🟢🟢🟢🟢⚪
              ⚪⚪🔴🟢🟢🟢🟢🟢🟢🔴🟢🟢⚪
              ⚪⚪⚪⚪⚪⚪⚪⚪⚪⚪🟢🟢⚪
              🟢🟢🟢🟢🟢🟢🟢🟢🟢🔴⚪🔴⚪

⚪⚪⚪⚪⚪⚪⚪⚪⚪⚪⚪⚪
🟢🟢🟢🟢🟢🟢🟢🔴🟢🟢🟢🔴
⚪⚪⚪⚪⚪⚪⚪⚪🟢🟢🟢🟢
⚪⚪🔴⚪⚪⚪⚪🔴🟢🟢🟢🟢
⚪⚪⚪🟢🟢🟢🟢🟢🟢🟢🟢🟢
⚪⚪🔴🟢🟢🟢🟢🟢🟢🔴🟢🟢
⚪⚪⚪⚪⚪⚪⚪⚪⚪⚪🟢🟢
🟢🟢🟢🟢🟢🟢🟢🟢🟢🔴⚪🔴

⚪⚪⚪⚪⚪⚪⚪⚪⚪⚪⚪⚪
🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢
⚪⚪⚪⚪⚪⚪⚪⚪🟢🟢🟢🟢
⚪⚪⚪⚪⚪⚪⚪⚪🟢🟢🟢🟢
⚪⚪⚪🟢🟢🟢🟢🟢🟢🟢🟢🟢
⚪⚪⚪🟢🟢🟢🟢🟢🟢🟢🟢🟢
⚪⚪⚪⚪⚪⚪⚪⚪⚪⚪🟢🟢
🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢⚪⚪


*/

      ) width
    ) height;

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
        inCorrectXspace  = !((vec.y < left.y  && vec.y  < right.y ) || (vec.y  > left.y  && vec.y  > right.y ));
        # inCorrectXspace = ((vec.y  < left.y  && vec.y  < right.y ) || (vec.y  > left.y  && vec.y  > right.y ));
        # point is before intersection of edge, traveling from low to high horizontally
        # Does the order of the points matter? should left.x always be less than right.x?
        inCorrectYspace =
          (vec.x ) <= trace "in slope???" (left.x )
          + (math.div0 (math.toFloat (vec.y - left.y ))  (math.toFloat (right.y - left.y) )) * ((right.x ) - (left.x ));
      in
      if inCorrectXspace /* && inCorrectYspace */ then count + 1 else count
      # if inCorrectXspace then count + 1 else count
    ) 0 edges
		|> trace "COUNT"
    |> math.isEven
    |> bool.not;

  part02 = input: input |> parseInput |> board |> builtins.map (lib.join "") |> lib.join "\n";
}
