{
  lib,
  stdenvNoCC,
  stdenv,
  fetchurl,
  patchelf,
}:

let
  version = "0.27.25";

  sources = {
    x86_64-linux = fetchurl {
      url = "https://github.com/backnotprop/plannotator/releases/download/v${version}/plannotator-linux-x64";
      hash = "sha256-ABr3dS+FQgJFifr8RK7DvifHMTOiw33zjwtZHCwUXdg=";
    };
    aarch64-linux = fetchurl {
      url = "https://github.com/backnotprop/plannotator/releases/download/v${version}/plannotator-linux-arm64";
      hash = "sha256-79ppKHm2gL+kzgSQcRme7F2t349pIcJiX6iKxWDLSJk=";
    };
    aarch64-darwin = fetchurl {
      url = "https://github.com/backnotprop/plannotator/releases/download/v${version}/plannotator-darwin-arm64";
      hash = "sha256-JN5g+/jjvatRl88635zjgeioGPLVSyoFX2EpHHsiYOo=";
    };
    x86_64-darwin = fetchurl {
      url = "https://github.com/backnotprop/plannotator/releases/download/v${version}/plannotator-darwin-x64";
      hash = "sha256-+kB7qjduNHj5/tjr4Tn4GZQtJiA/hUQubniAxxWJ+Hc=";
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
