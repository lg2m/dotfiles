{
  lib,
  stdenvNoCC,
  stdenv,
  fetchurl,
  patchelf,
}:

let
  version = "0.28.33";

  sources = {
    x86_64-linux = fetchurl {
      url = "https://github.com/backnotprop/plannotator/releases/download/v${version}/plannotator-linux-x64";
      hash = "sha256-qSKYdGmHQyEExg5TIcmVsC5GKAnNVZb/Sx+qbdZhNkg=";
    };
    aarch64-linux = fetchurl {
      url = "https://github.com/backnotprop/plannotator/releases/download/v${version}/plannotator-linux-arm64";
      hash = "sha256-fAgqODVufeNtBjnqz8izrKIxtdIcXwZCPK2eErwV/xM=";
    };
    aarch64-darwin = fetchurl {
      url = "https://github.com/backnotprop/plannotator/releases/download/v${version}/plannotator-darwin-arm64";
      hash = "sha256-C9zdlV2cPCMiHl1T5EFCw25y6YcYtcqaeOQb9URgUBg=";
    };
    x86_64-darwin = fetchurl {
      url = "https://github.com/backnotprop/plannotator/releases/download/v${version}/plannotator-darwin-x64";
      hash = "sha256-PruBf8B7jbbugsa7jf0OVigTDvLjhUZepES2l5xoXEI=";
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
