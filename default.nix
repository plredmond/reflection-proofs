{ config ? { allowBroken = true; }, ... }:
let
  # get pinned/overridden haskellPackages containing LH
  lh-source = (import <nixpkgs> { }).fetchFromGitHub {
    owner = "plredmond";
    repo = "liquidhaskell";
    rev = "a4b24ab24462334063210c6994fd1f4eeadcd57a"; # nixify branch
    sha256 = "0jvbvzyhvj3cy05zx02hvi59ymqmlxrfdm6fvm08nx7hb2922qva";
    fetchSubmodules = true;
  };
  # extract pinned nixpkgs and haskellPackages
  elsewhere = import lh-source { inherit config; tests = false; mkEnv = false; };
  nixpkgs = elsewhere.nixpkgs;
  haskellPackages = elsewhere.haskellPackages.override (
    old: {
      overrides = self: super: with nixpkgs.haskell.lib; (old.overrides self super) // {
        tls = self.callHackage "tls" "1.5.4" { }; # nixpkgs version too old for hpack
      };
    }
  );
  # define the derivation and the environment
  src = nixpkgs.nix-gitignore.gitignoreSource [ ] ./.;
  drv = nixpkgs.haskell.lib.overrideCabal
    (haskellPackages.callCabal2nix "reflection-proofs" src { })
    (
      old: {
        doCheck = true;
        doHaddock = false; # FIXME: bug in LH, https://github.com/ucsd-progsys/liquidhaskell/issues/1727
        buildTools = old.buildTools or [ ] ++ [ nixpkgs.z3 ];
      }
    );
  env = (drv.envFunc { withHoogle = true; }).overrideAttrs
    (old: { nativeBuildInputs = old.nativeBuildInputs ++ [ nixpkgs.ghcid haskellPackages.doctest ]; });
in
if nixpkgs.lib.inNixShell then env else drv
