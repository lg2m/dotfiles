{
  lib,
  stdenvNoCC,
  fetchurl,
  buildFHSEnv ? null,
}:

let
  version = "2.1.1";

  sources = {
    x86_64-linux = fetchurl {
      url = "https://github.com/schpet/linear-cli/releases/download/v${version}/linear-x86_64-unknown-linux-gnu.tar.xz";
      hash = "sha256-aMrqS0lPY57/pmEmYrtii6fz+M123bznsqnJYrsBSmQ=";
    };
    aarch64-linux = fetchurl {
      url = "https://github.com/schpet/linear-cli/releases/download/v${version}/linear-aarch64-unknown-linux-gnu.tar.xz";
      hash = "sha256-uKdeImYkYOhwriV1ordRCg0MRSntZC2tPQvRdTI8flI=";
    };
    aarch64-darwin = fetchurl {
      url = "https://github.com/schpet/linear-cli/releases/download/v${version}/linear-aarch64-apple-darwin.tar.xz";
      hash = "sha256-HfXZVYWn01wEb6MzAfJ6zZSDws3ctmiC0S8aEf58HC0=";
    };
    x86_64-darwin = fetchurl {
      url = "https://github.com/schpet/linear-cli/releases/download/v${version}/linear-x86_64-apple-darwin.tar.xz";
      hash = "sha256-GeQR4wWpCz5rvd/8iwyTq54mr30Hdhvkg9aPRQ4N/MM=";
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
