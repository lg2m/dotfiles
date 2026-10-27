# OpenAI Codex CLI pinned ahead of nixpkgs. Drop this directory once nixpkgs
# catches up; the overlay then falls back to pkgs.codex from nixpkgs.
#
# nixpkgs builds codex with finalAttrs, so overriding version/buildCommit/
# cargoHash re-derives src rev and cargoDeps (including its opus patch).
{
  lib,
  stdenv,
  codex,
  fetchFromGitHub,
  fetchurl,
}:
let
  version = "0.164.0";
  # `git rev-parse rust-v${version}`; build_id() requires the full SHA.
  buildCommit = "6aaac694803004a63c6f393d153c96d22521a6b9";

  # rusty_v8 prebuilts matching the `v8` crate in codex-rs/Cargo.lock.
  v8Version = "152.2.0";
  v8Hashes = {
    x86_64-linux = {
      archive = "sha256-tmg+mvy3f72MssOs9F001SApqyFrMyUiyVF5wS8P7Tw=";
      binding = "sha256-Pk1f7Nvg+YpgF+adfKglGad/sDLF615M2+zdPi7FGdU=";
    };
    aarch64-linux = {
      archive = "sha256-xAGWu/GCUy5YP2W32vAZb9uzNU5vrFmzHQU5wg+THz0=";
      binding = "sha256-Pk1f7Nvg+YpgF+adfKglGad/sDLF615M2+zdPi7FGdU=";
    };
    aarch64-darwin = {
      archive = "sha256-pKVIREStS18Q3HvtFBI23Z2+q/IAbRRSDxm5NdTbQic=";
      binding = "sha256-udVlLrylFesr9MLuSmVRslZxF7Wqcg9DDSAyYW3X47U=";
    };
  };
  inherit (stdenv.hostPlatform) system;
  target = stdenv.hostPlatform.rust.rustcTarget;
  hashes = v8Hashes.${system} or (throw "codex: no rusty_v8 hashes for ${system}");
  v8Url = "https://github.com/denoland/rusty_v8/releases/download/v${v8Version}";
  librusty_v8 = fetchurl {
    name = "librusty_v8-${v8Version}";
    url = "${v8Url}/librusty_v8_release_${target}.a.gz";
    hash = hashes.archive;
  };
  librusty_v8_src_binding = fetchurl {
    name = "src_binding-${v8Version}";
    url = "${v8Url}/src_binding_release_${target}.rs";
    hash = hashes.binding;
  };
in
codex.overrideAttrs (
  finalAttrs: previousAttrs: {
    inherit version buildCommit;

    src = fetchFromGitHub {
      owner = "openai";
      repo = "codex";
      rev = finalAttrs.buildCommit;
      hash = "sha256-iib2+qQcGewC4Ga8cA80sInDJpzdSxDJP0y1DDOouI4=";
    };

    cargoHash = "sha256-0N2mEGqEl2ZjWqlbraVCWP0eoITgwmT9uO/1w/1eJno=";

    # Upstream now carries `#![recursion_limit = "256"]` in chatgpt/src/lib.rs;
    # drop nixpkgs' sed that would add a duplicate.
    postPatch =
      lib.replaceStrings [ ''sed -i '1i#![recursion_limit = "256"]' chatgpt/src/lib.rs'' ] [ "" ]
        previousAttrs.postPatch;

    env = previousAttrs.env // {
      CODEX_BUILD_COMMIT = finalAttrs.buildCommit;
      STABLE_GIT_COMMIT = finalAttrs.buildCommit;
      RUSTY_V8_ARCHIVE = librusty_v8;
      RUSTY_V8_SRC_BINDING_PATH = librusty_v8_src_binding;
    };
  }
)
