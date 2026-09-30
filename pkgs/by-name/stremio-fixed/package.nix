{
  stremio-linux-shell,
  libayatana-appindicator,
  libxkbcommon,
}:

stremio-linux-shell.overrideAttrs (oldAttrs: {
  postPatch = (oldAttrs.postPatch or "") + ''
    for file in $cargoDepsCopy/libappindicator-sys-*/src/lib.rs; do
      if [ ! -e "$file" ]; then
        break
      fi

      substituteInPlace "$file" \
        --replace-fail "libayatana-appindicator3.so.1" "${libayatana-appindicator}/lib/libayatana-appindicator3.so.1"
    done

    for file in $cargoDepsCopy/xkbcommon-dl-*/src/lib.rs; do
      if [ ! -e "$file" ]; then
        break
      fi

      substituteInPlace "$file" \
        --replace-fail "libxkbcommon.so.0" "${libxkbcommon}/lib/libxkbcommon.so.0"
    done

    for file in $cargoDepsCopy/xkbcommon-dl-*/src/x11.rs; do
      if [ ! -e "$file" ]; then
        break
      fi

      substituteInPlace "$file" \
        --replace-fail "libxkbcommon-x11.so.0" "${libxkbcommon}/lib/libxkbcommon-x11.so.0"
    done
  '';
})
