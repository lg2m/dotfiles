# OpenAI Codex CLI pinned ahead of nixpkgs. Drop this directory once nixpkgs
# catches up; the overlay then falls back to pkgs.codex from nixpkgs.
{
  codex,
  fetchFromGitHub,
  rustPlatform,
}:
let
  version = "0.163.0";
  src = fetchFromGitHub {
    owner = "openai";
    repo = "codex";
    tag = "rust-v${version}";
    hash = "sha256-Fa9dfiGJy+uqSF4A0EM6AQQhhjQdu+jfhKzqXid9PNA=";
  };
in
codex.overrideAttrs (
  _finalAttrs: previousAttrs: {
    inherit version src;
    sourceRoot = "${src.name}/codex-rs";

    # Upstream pins rustc 1.95; newer rustc in nixpkgs overflows the default
    # query depth (128) laying out `connectors::list_connectors()`.
    postPatch = (previousAttrs.postPatch or "") + ''
      sed -i '1i #![recursion_limit = "256"]' chatgpt/src/lib.rs
    '';

    cargoDeps = rustPlatform.fetchCargoVendor {
      inherit (previousAttrs) pname;
      inherit version src;
      sourceRoot = "${src.name}/codex-rs";
      hash = "sha256-TG1fDHQCRDDbk+G0NS/9NTouJupq0Zisi4LIJY4SgYw=";
    };
  }
)
