{ config ? { allowBroken = true; }, ... }:
let
  # get pinned/overridden haskellPackages containing LH
  lh-source = (import <nixpkgs> { }).fetchFromGitHub {
    owner = "plredmond";
    repo = "liquidhaskell";
    rev = "d990ebd8c6bcc4f4ade7e04048da9bfcaceff39d"; # nixify branch built from LH `develop` branch source Mon 01 Feb 2021 06:39:59 AM UTC
    sha256 = "0h9pw463r2knr27baj5gb01ccdlwwv7x7xdm9swb39k8mfcyh9y6";
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
    (old: { nativeBuildInputs = old.nativeBuildInputs ++ [ nixpkgs.ghcid ]; });
in
if nixpkgs.lib.inNixShell then env else drv
