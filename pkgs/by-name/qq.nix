{
  lib,
  rustPlatform,
  fetchFromGitHub,
  cacert,
}:

rustPlatform.buildRustPackage rec {
  pname = "qq";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "retsu-AI";
    repo = "qq";
    rev = "51ccf13d347103e9569dbe3892341b3eb1f6e978";
    hash = "sha256-x1YwbS68PKDJBTJmq61M4gcYqVGM//xCPQCBQ25D7Z0=";
  };

  cargoHash = "sha256-BqD6riF6+DdptHjHG1QKiCq/hX1xsdRx6cmaV06wF/o=";

  QQ_GIT_SHA = "51ccf13";
  QQ_GIT_FULL_SHA = "51ccf13d347103e9569dbe3892341b3eb1f6e978";
  QQ_GIT_DATE = "2026-09-19";

  cargoBuildFlags = [ "--package=qq" ];
  cargoTestFlags = [ "--package=qq" ];
  nativeCheckInputs = [ cacert ];

  meta = {
    description = "Terminal-native agent harness";
    homepage = "https://github.com/retsu-AI/qq";
    license = lib.licenses.mit;
    mainProgram = "qq";
  };
}
