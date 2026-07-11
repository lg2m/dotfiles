{
  lib,
  stdenvNoCC,
  stdenv,
  fetchurl,
  patchelf,
  unzip,
}:

let
  version = "1.5.32";

  sources = {
    x86_64-linux = fetchurl {
      url = "https://github.com/UsefulSoftwareCo/executor/releases/download/v${version}/executor-linux-x64.tar.gz";
      hash = "sha256-N8KsbVkhJLwivfbofM/U8sdz0mw6522aSlVnXJAeSEQ=";
    };
    aarch64-linux = fetchurl {
      url = "https://github.com/UsefulSoftwareCo/executor/releases/download/v${version}/executor-linux-arm64.tar.gz";
      hash = "sha256-2tJnsW6SyB8v3kWz6+j+cXLZ7adekv2+2x79XKNkmbw=";
    };
    aarch64-darwin = fetchurl {
      url = "https://github.com/UsefulSoftwareCo/executor/releases/download/v${version}/executor-darwin-arm64.zip";
      hash = "sha256-hbdeGcUgUQH3tOZvSs6jKeXGJ7PsPHSQuDVmKqQdW1M=";
    };
    x86_64-darwin = fetchurl {
      url = "https://github.com/UsefulSoftwareCo/executor/releases/download/v${version}/executor-darwin-x64.zip";
      hash = "sha256-V8OohDEnHoppQJ4Cws/wnZEi/swlqEi45eaBjNS0h9U=";
    };
  };

  isDarwin = stdenvNoCC.hostPlatform.isDarwin;

  # Runtime libraries needed by the bundled native addons (*.node) and workerd.
  runtimeLibs = lib.makeLibraryPath [
    stdenv.cc.cc.lib # libgcc_s, libstdc++
  ];
in
stdenvNoCC.mkDerivation {
  pname = "executor";
  inherit version;

  src =
    sources.${stdenvNoCC.hostPlatform.system}
      or (throw "Unsupported system: ${stdenvNoCC.hostPlatform.system}");

  # The `executor` binary is a Bun single-executable app with its JS bundle
  # appended after the ELF sections; autoPatchelfHook would truncate that
  # appended payload, so it must not be used. We patch only the interpreter.
  nativeBuildInputs =
    lib.optionals stdenvNoCC.hostPlatform.isLinux [ patchelf ] ++ lib.optionals isDarwin [ unzip ];

  dontAutoPatchelf = true;

  # The zip sources have a flat layout; the tarballs unpack into the cwd too.
  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    # Keep the whole distribution together; the binary resolves its own real
    # path to locate sibling native addons (keyring.node, libsql.node, workerd,
    # *.wasm, worker-bundler/).
    mkdir -p $out/libexec/executor
    cp -r ./* $out/libexec/executor/
    chmod +x $out/libexec/executor/executor $out/libexec/executor/workerd

    mkdir -p $out/bin
    ln -s $out/libexec/executor/executor $out/bin/executor

    runHook postInstall
  '';

  postFixup = lib.optionalString stdenvNoCC.hostPlatform.isLinux ''
    interp="$(< ${stdenv.cc}/nix-support/dynamic-linker)"
    d=$out/libexec/executor

    # Patch the ELF interpreter only on the Bun SEA to preserve the appended payload.
    patchelf --set-interpreter "$interp" "$d/executor"

    # workerd and the native addons are ordinary ELF objects; give them an
    # interpreter/rpath so they can find glibc, libgcc_s, and libstdc++.
    patchelf --set-interpreter "$interp" --set-rpath "${runtimeLibs}" "$d/workerd"
    for lib in "$d"/*.node; do
      patchelf --set-rpath "${runtimeLibs}" "$lib" || true
    done
  '';

  meta = {
    description = "Executor local CLI for running and supervising AI tool integrations";
    homepage = "https://executor.sh";
    license = lib.licenses.unfree;
    platforms = builtins.attrNames sources;
    mainProgram = "executor";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}
