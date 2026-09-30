{
  lib,
  stdenvNoCC,
  fetchurl,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "qq";
  version = "0.1.4";

  src = fetchurl {
    url = "https://github.com/retsu-AI/qq/releases/download/v${finalAttrs.version}/qq-v${finalAttrs.version}-x86_64-unknown-linux-musl.tar.gz";
    hash = "sha256-wYFdL5cAYsNQKGKSzt6w34gAtdco4/uCyJwnD993ThE=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 qq -t "$out/bin"
    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    "$out/bin/qq" --version | grep -q "^qq ${finalAttrs.version} "
    runHook postInstallCheck
  '';

  meta = {
    description = "AI coding agents in one binary: terminal UI, headless runner, and local server";
    homepage = "https://github.com/retsu-AI/qq";
    license = lib.licenses.mit;
    mainProgram = "qq";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
