{ lib, ... }:
let
  utils = import ../utils.nix { inherit lib; };
  inherit (utils) math string tuple set trace;
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

  # expect01 = 3;
  # expect02 = 6;
  # expectReal01 = 989;
  # expectReal02 = 5941;

  # input = builtins.readFile ./input/day09.txt;

	parseInput = str: str;
  
  part01 =
    input:
    input
    ;

  part02 =
    input:
    input
    ;

}
