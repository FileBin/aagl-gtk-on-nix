let
  flake = (import (
    let
      lock = builtins.fromJSON (builtins.readFile ./flake.lock);
    in
      fetchTarball {
        url = "https://github.com/edolstra/flake-compat/archive/${lock.nodes.flake-compat.locked.rev}.tar.gz";
        sha256 = lock.nodes.flake-compat.locked.narHash;
      }
    ) {
      src = ./.;
    }
  ).defaultNix;

  # Get the pinned nixpkgs
  nixpkgs-nonfree = import flake.inputs.nixpkgs {
    system = "x86_64-linux";
    config.allowUnfree = true;
  };

  outputs = pkgs: with flake.outputs; (packages.x86_64-linux.withNixpkgs pkgs) // {
    module = import ./module (outputs pkgs);
    overlay = overlays.default;
    # Provide a mechanism for non-flake users to override nixpkgs.
    # nixos unstable environment is often incompatible with stable nixpkgs runtimes.
    withNixpkgs = p: outputs p;
  };
in outputs nixpkgs-nonfree
