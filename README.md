# Reflection Proofs

This is a practice repository of proofs written in Liquid Haskell in the style
of [Theorem Proving for All](https://arxiv.org/pdf/1806.03541.pdf) by Niki
Vazou.

Since the repository only contains proofs, there's nothing to run. You can
check the proofs by compiling the code with the Liquid Haskell plugin.

# Compile & Check the Proofs

To complthe code, use haskell stack or nix.

## Nix

Run `nix-build`.

![It's safe!](build.png)

## Stack

Run `stack build`. If using `stack` on nix be sure to eable nix integration in the `stack.yaml`.
