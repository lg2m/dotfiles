{
  lib,
  fetchurl,
  appimageTools,
}:

let
  pname = "helium";
  version = "0.14.6.1";

  src = fetchurl {
    url = "https://github.com/imputnet/helium-linux/releases/download/${version}/${pname}-${version}-x86_64.AppImage";
    hash = "sha256-qdM1Qysx5OOBwzr6A6tyPIfZcHxn2YkIPedGelvbk7I=";
  };

  contents = appimageTools.extractType2 { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    # Install upstream desktop entry
    if [ -f "${contents}/${pname}.desktop" ]; then
      install -m 444 -D "${contents}/${pname}.desktop" "$out/share/applications/${pname}.desktop"
    elif [ -f "${contents}/usr/share/applications/${pname}.desktop" ]; then
      install -m 444 -D "${contents}/usr/share/applications/${pname}.desktop" "$out/share/applications/${pname}.desktop"
    else
      echo "Could not find ${pname}.desktop in AppImage contents"
      echo "Top-level files:"
      find "${contents}" -maxdepth 3 -type f | sed 's|^|  |' | head -n 200
      exit 1
    fi

    # Patch Exec line to use the wrapped binary name
    substituteInPlace "$out/share/applications/${pname}.desktop" \
      --replace 'Exec=AppRun' 'Exec=${pname}' \
      --replace 'Exec=./AppRun' 'Exec=${pname}' \
      --replace 'Exec=AppRun %U' 'Exec=${pname} %U' \
      --replace 'Exec=./AppRun %U' 'Exec=${pname} %U'

    # Copy icons shipped by upstream (this is the reliable bit)
    if [ -d "${contents}/usr/share/icons" ]; then
      mkdir -p "$out/share"
      cp -r "${contents}/usr/share/icons" "$out/share/"
    else
      echo "No usr/share/icons in AppImage contents"
    fi
  '';

  meta = {
    description = "Helium Browser";
    homepage = "https://github.com/imputnet/helium-linux";
    license = lib.licenses.unfreeRedistributable;
    platforms = [ "x86_64-linux" ];
    mainProgram = "helium";
  };
}
