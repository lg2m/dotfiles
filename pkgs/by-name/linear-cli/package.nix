{
  lib,
  stdenvNoCC,
  fetchurl,
  buildFHSEnv ? null,
}:

let
  version = "2.6.0";

  sources = {
    x86_64-linux = fetchurl {
      url = "https://github.com/schpet/linear-cli/releases/download/v${version}/linear-x86_64-unknown-linux-gnu.tar.xz";
      hash = "sha256-u8udNlMIvDcooeyZE60YgPiMDOaHZzgyl+NIwFfzW40=";
    };
    aarch64-linux = fetchurl {
      url = "https://github.com/schpet/linear-cli/releases/download/v${version}/linear-aarch64-unknown-linux-gnu.tar.xz";
      hash = "sha256-VcxKaySJpAOtnrgPYS36hBKHv6FrmDkLtNTgcteeI2E=";
    };
    aarch64-darwin = fetchurl {
      url = "https://github.com/schpet/linear-cli/releases/download/v${version}/linear-aarch64-apple-darwin.tar.xz";
      hash = "sha256-uavdS1rsFEWeQ0oomSA3V96K6EfwVerk8frue7H7wHg=";
    };
    x86_64-darwin = fetchurl {
      url = "https://github.com/schpet/linear-cli/releases/download/v${version}/linear-x86_64-apple-darwin.tar.xz";
      hash = "sha256-CKuhmvTwBinl6JqwQBfTHRhXP7ydySIoCChwL9riej8=";
    };
  };

  src =
    sources.${stdenvNoCC.hostPlatform.system}
      or (throw "Unsupported system: ${stdenvNoCC.hostPlatform.system}");

  meta = {
    description = "CLI for the Linear issue tracker";
    homepage = "https://github.com/schpet/linear-cli";
    license = lib.licenses.mit;
    platforms = builtins.attrNames sources;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    mainProgram = "linear";
  };

  unwrapped = stdenvNoCC.mkDerivation {
    pname = "linear-cli-unwrapped";
    inherit version src meta;

    dontAutoPatchelf = true;
    dontStrip = true;

    installPhase = ''
      runHook preInstall
      install -Dm755 linear $out/bin/linear
      install -Dm644 LICENSE $out/share/licenses/linear-cli/LICENSE
      install -Dm644 README.md $out/share/doc/linear-cli/README.md
      install -Dm644 CHANGELOG.md $out/share/doc/linear-cli/CHANGELOG.md
      runHook postInstall
    '';
  };
in
if stdenvNoCC.hostPlatform.isLinux then
  buildFHSEnv {
    pname = "linear-cli";
    inherit version meta;

    targetPkgs = _: [ unwrapped ];
    runScript = "linear";
    executableName = "linear";

    passthru = { inherit unwrapped; };
  }
else
  unwrapped.overrideAttrs (_: {
    pname = "linear-cli";
  })
