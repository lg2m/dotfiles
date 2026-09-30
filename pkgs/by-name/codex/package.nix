# OpenAI Codex CLI pinned ahead of nixpkgs. Drop this directory once nixpkgs
# catches up; the overlay then falls back to pkgs.codex from nixpkgs.
{
  codex,
  fetchFromGitHub,
  rustPlatform,
}:
let
  version = "0.153.4";
  src = fetchFromGitHub {
    owner = "openai";
    repo = "codex";
    tag = "rust-v${version}";
    hash = "sha256-lHiDj5SodaM3mh8goMm6esfejeAT+Y3JJWrRnyj6sJo=";
  };
in
codex.overrideAttrs (
  _finalAttrs: previousAttrs: {
    inherit version src;
    sourceRoot = "${src.name}/codex-rs";

    cargoDeps = rustPlatform.fetchCargoVendor {
      inherit (previousAttrs) pname;
      inherit version src;
      sourceRoot = "${src.name}/codex-rs";
      hash = "sha256-GG6kOXmCdq+bZLU2ul0DIVL8lDuweayvZvXn6+bcUZw=";
    };
  }
)
