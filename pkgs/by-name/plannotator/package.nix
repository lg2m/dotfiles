{
  lib,
  stdenvNoCC,
  stdenv,
  fetchurl,
  patchelf,
}:

let
  version = "0.27.9";

  sources = {
    x86_64-linux = fetchurl {
      url = "https://github.com/backnotprop/plannotator/releases/download/v${version}/plannotator-linux-x64";
      hash = "sha256-HTPiAEDxfrefG3UgsCY/dgPCNkaevqourQUoHC0rWF0=";
    };
    aarch64-linux = fetchurl {
      url = "https://github.com/backnotprop/plannotator/releases/download/v${version}/plannotator-linux-arm64";
      hash = "sha256-025nGOCAt6ABeWXiBXp5aHNmyltWWUnYFld3z8ZQrhI=";
    };
    aarch64-darwin = fetchurl {
      url = "https://github.com/backnotprop/plannotator/releases/download/v${version}/plannotator-darwin-arm64";
      hash = "sha256-PK8OY7qR+a9FTdtA6/sF9o2g2bpYi+/+2XTpiz4zrvU=";
    };
    x86_64-darwin = fetchurl {
      url = "https://github.com/backnotprop/plannotator/releases/download/v${version}/plannotator-darwin-x64";
      hash = "sha256-8/yNu0gbLHjNYjEiruia6016hq0EN6B/rwRfuFn2cR8=";
    };
  };
in
stdenvNoCC.mkDerivation {
  pname = "plannotator";
  inherit version;

  src =
    sources.${stdenvNoCC.hostPlatform.system}
      or (throw "Unsupported system: ${stdenvNoCC.hostPlatform.system}");

  # autoPatchelfHook must NOT be used here. This is a Bun single-executable
  # binary with the JS bundle appended after the ELF sections. autoPatchelfHook
  # truncates that appended data, leaving only the bare Bun runtime.
  nativeBuildInputs = lib.optionals stdenvNoCC.hostPlatform.isLinux [ patchelf ];

  dontUnpack = true;
  dontAutoPatchelf = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/bin/plannotator
    runHook postInstall
  '';

  # Manually patch only the ELF interpreter so the appended Bun payload is preserved.
  postFixup = lib.optionalString stdenvNoCC.hostPlatform.isLinux ''
    patchelf --set-interpreter "$(< ${stdenv.cc}/nix-support/dynamic-linker)" $out/bin/plannotator
  '';

  meta = {
    description = "Interactive code review and annotation tool for AI coding agents";
    homepage = "https://github.com/backnotprop/plannotator";
    license = with lib.licenses; [
      asl20
      mit
    ];
    platforms = builtins.attrNames sources;
    mainProgram = "plannotator";
  };
}
