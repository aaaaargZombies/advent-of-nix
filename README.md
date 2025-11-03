# Advent Of Code in Nix

An exploration of nix the lang as I've only really used it to manage system deps for the odd dev shell.

> [Advent of Code](https://adventofcode.com/2025/about) is an Advent calendar of small programming puzzles for a variety of skill levels that can be solved in any programming language you like.

## running

```sh
nix flake check --print-build-logs
```

Note this runs by building the checks output, so if nothing changes you won't see any output on the build.

## resources

Some useful looking resources.

- [Nix explained from the ground up](https://www.youtube.com/watch?v=5D3nUU1OVx8) a nice video giving a birds eye view of nix.
- doing AOC in nix!
  - [The Nix Hour #59 \[programming puzzle\]](https://www.youtube.com/watch?v=0Xl_hCrBfxQ&list=PLyzwHTVJlRc8yjlx4VR4LU5A5O44og9in&index=24)
  - [The Nix Hour #61 \[programming puzzle, part 2\]](https://www.youtube.com/watch?v=jfRKCRdf9NM&list=PLyzwHTVJlRc8yjlx4VR4LU5A5O44og9in&index=22)
- tesing nix
  - [The Nix Hour #20 \[nixos tests\]](https://www.youtube.com/watch?v=RgKl8Jue4qM&list=PLyzwHTVJlRc8yjlx4VR4LU5A5O44og9in&index=63)
  - [ The Nix Hour #7 \[source filtering, writing package tests\] ](https://www.youtube.com/watch?v=mOQI9Iiu4Uc&list=PLyzwHTVJlRc8yjlx4VR4LU5A5O44og9in&index=76)
- many other useful looking vids in the Nix Hour playlist
- tesing libs
  - [nix-unit - Unit testing for Nix code](https://github.com/nix-community/nix-unit) last update at time of writing last month
  - [nixt - Simple unit-testing for Nix](https://github.com/nix-community/nixt) last update at time of writing last year
  - both seem to be part of `nix-community` org
  - there is also [namaka - Snapshot testing for Nix based on haumea](https://github.com/nix-community/namaka) which might make sense as a workflow for wworking through the parsing parts but looks a bit more involved to set up.
- [noogle](https://noogle.dev/) function search for nix, try `lib.<???>` / `builtins.<???>`
