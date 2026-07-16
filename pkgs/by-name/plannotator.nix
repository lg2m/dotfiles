{
  lib,
  stdenvNoCC,
  stdenv,
  fetchurl,
  patchelf,
}:

let
  version = "0.23.1";

  sources = {
    x86_64-linux = fetchurl {
      url = "https://github.com/backnotprop/plannotator/releases/download/v${version}/plannotator-linux-x64";
      hash = "sha256-FIH1FD+BCBd/4M2xXRTy3DoYgzswEuMPGIxyMOA0O6c=";
    };
    aarch64-linux = fetchurl {
      url = "https://github.com/backnotprop/plannotator/releases/download/v${version}/plannotator-linux-arm64";
      hash = "sha256-E0UBvkTQcUEKnhUx/jAZOY6iXzd28HPBUzPXrIoPO18=";
    };
    aarch64-darwin = fetchurl {
      url = "https://github.com/backnotprop/plannotator/releases/download/v${version}/plannotator-darwin-arm64";
      hash = "sha256-2BzH2MrM/EaJTL4WQblmMXcNsvOWtJpY4q1f7icVBfE=";
    };
    x86_64-darwin = fetchurl {
      url = "https://github.com/backnotprop/plannotator/releases/download/v${version}/plannotator-darwin-x64";
      hash = "sha256-VTHT4frItoThSewpckMyTADMI1zkcdt8CQFjRnOenTU=";
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
