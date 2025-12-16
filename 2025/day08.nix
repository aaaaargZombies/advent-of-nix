{ lib, ... }:
let
  utils = import ../utils.nix { inherit lib; };
  inherit (utils)
    string
    list
    tuple
    math
    ;
in
rec {

  sampleInput = ''
    162,817,812
    57,618,57
    906,360,560
    592,479,940
    352,342,300
    466,668,158
    542,29,236
    431,825,988
    739,650,466
    52,470,668
    216,146,977
    819,987,18
    117,168,530
    805,96,715
    346,949,466
    970,615,88
    941,993,340
    862,61,35
    984,92,344
    425,690,689
  '';

  expect01 = 40;
  # expect02 = 40;
  # expectReal01 = 1579;
  # expectReal02 = 13418215871354;

  input = builtins.readFile ./input/day08.txt;

  toVec =
    str:
    str
    |> lib.splitString ","
    |> map lib.toIntBase10
    |> (xyz: {
      x = list.at 0 xyz;
      y = list.at 1 xyz;
      z = list.at 2 xyz;
    });

  parseInput = str: str |> string.lines |> map toVec;

  distance =
    a: b:
    let
      x2 = math.square (b.x - a.x);
      y2 = math.square (b.y - a.y);
      z2 = math.square (b.z - a.z);
      sum = x2 + y2 + z2;
    in
    math.sqrt sum;

  closest10 =
    vecs:
    vecs
    |> list.combinations 2
    |> map (ps: tuple.pair (distance (list.at 0 ps) (list.at 1 ps)) ps)
    |> builtins.sort (a: b: a.left < b.left)
    # |> utils.trace "🔗 distances"
    |> map tuple.snd
    |> lib.take 10
    |> utils.trace "TAKE 10";

  pairsToCicuits =
    xss:
    let
      head = lib.take 1 xss;
      tail = lib.drop 1 xss;
    in
    builtins.foldl' (
      acc: connection:
      let
        pair =
          builtins.foldl'
            (
              { acc_, added }:
              circ:
              let
                l = list.at 0 connection;
                r = list.at 1 connection;
              in
              # if added then
              #   {
              #     acc_ = utils.trace "1" <|acc_ ++ [ circ ];
              #     added = added;
              #   }
              # else
              if builtins.any (ps: builtins.any (v: v == l || v == r) ps) circ then
                # I think I need to keep the pairs not so a circuit is a list of pairs not
                # [
                #   { "x": 162, "y": 817, "z": 812 },
                #   { "x": 425, "y": 690, "z": 689 },
                #   { "x": 431, "y": 825, "z": 988 },
                #   { "x": 346, "y": 949, "z": 466 }
                # ],
                {
                  acc_ = utils.trace "ONE" <| acc_ ++ [ (circ ++ [ connection ]) ];
                  added = true;
                }

              else
                {
                  acc_ = utils.trace "TWO" <| acc_ ++ [ circ ];
                  added = added;
                }
            )
            {
              acc_ = [ ];
              added = false;
            }
            acc;
      in
      if pair.added then pair.acc_ else utils.trace "THREE" <| acc ++ [ [ connection ] ]
    ) [ head ] tail;

  /**
    	represent the circuit as a tree.
    	- attrs { Vec =  parent Vec }
    	- attrs { (builtins.toJson Vec) =  (builtins.toJson Vec) }

    	- group circuits by finding the root
    	- flatten the tree by setting the root as the parent
  */

  startTree =
    xss:
    xss
    |> lib.flatten
    |> lib.unique
    |> builtins.map builtins.toJSON
    |> builtins.foldl' (acc: el: acc // { ${el} = el; }) { };

  root = a: tree: if tree.${a} == a then a else root tree.${a} tree;

  merge =
    a: b: tree:
    tree // { ${root (utils.trace "B" b) tree} = root (utils.trace "A" a) tree; }; # FIX: this won't do compaction, so we'll get a->b b->c instead a->c b->c

  /*
    		FIX: my problem is that if the same element get's linked to a different route then all three elements aren't connected
    		[
          [
            { "x": 162, "y": 817, "z": 812 },
            { "x": 425, "y": 690, "z": 689 }
          ],
          [
            { "x": 162, "y": 817, "z": 812 },
            { "x": 431, "y": 825, "z": 988 } <- linking this overwrites the one above.
          ],
    	  ]
  */

  countTree =
    key: tree:
    if tree.${key} == tree then
      0
    else
      # this can cause a loop because there is not a guarentee that there is a bottom
      # a -> b -> c -> a
      1 + (countTree tree.${key} tree);

  pairsToCircuits' =
    tree: xss:
    let
      # I think the start tree needs to be the individual ciruits, not the conncections
      # that leaves the individual junctions as their own circuits at the end?
      # tree = startTree xss;
      vecs =
        xss |> builtins.map tuple.fromList |> builtins.map (tuple.mapBoth builtins.toJSON builtins.toJSON);
      # firstPass = builtins.foldl' (acc: {left, right}: merge left right acc ) tree vecs;
    in
    # builtins.foldl' (acc: {name, value}: merge name value acc ) firstPass (lib.attrsToList firstPass);
    builtins.foldl' (acc: { left, right }: merge left right (utils.trace "MERGING" acc)) tree vecs;

  countCircuits =
    tree: tree |> builtins.attrNames |> builtins.foldl' (acc: key: acc ++ [ (countTree key tree) ]) [ ];

  # NOTE: just make a normal tree?

  /**
    	represent the circuit as a tree.
    	- attrs { Vec =  parent Vec }
    	- attrs { (builtins.toJson Vec) =  [(builtins.toJson Vec) ]}
    	- attrs { string = [string]}

    	- group circuits by finding the root
    	- flatten the tree by setting the root as the parent
  */

  vecsToTree =
    xs: xs |> builtins.map (vec: lib.nameValuePair (builtins.toJSON vec) [ ]) |> builtins.listToAttrs;

  countCircuitSize =
    vec: tree:
    let
      children = tree.${vec};
    in
    if tree.${vec} == [ ] then
      1
    else
      children |> builtins.map (child: countCircuitSize child tree) |> list.sum |> (sum: sum + 1);

  addConnection =
    tree:
    { left, right }:
    let
      children = tree.${left};
    in
    if builtins.elem right children then tree else tree // { ${left} = (children ++ [ right ]); };

  createCircuits =
    connections: tree:
    let
      stringified =
        connections |> builtins.map (xs: xs |> builtins.map builtins.toJSON |> tuple.fromList);
    in
    builtins.foldl' addConnection tree stringified;

  allSizes =
    tree:
    let
      vecs = builtins.attrNames tree;
    in
    builtins.foldl' (counts: vec: counts ++ [ (countCircuitSize vec tree) ]) [ ] vecs;

  /*
        - find 10 shortest connections
    		- collect into circuits (connected vecs)
        - take 3 largest circuits
        - count the nodes in each circuit
        - times the circuit sizes together
  */

  # part01 = input: input |> parseInput |> closest10 |> pairsToCicuits |> (circs: circs |> map (c: c|> lib.flatten |> lib.unique |> builtins.length)) ;
  part01 =
    input:
    input
    |> parseInput
    |> (vs: createCircuits (closest10 vs) (vecsToTree vs))
    |> utils.trace "CIRCUITS!!!"
    |> allSizes
    |> builtins.sort (a: b: a > b);
  # part01 = input: input |> parseInput |> closest10 |> pairsToCicuits ;

  part02 = input: input;

}
