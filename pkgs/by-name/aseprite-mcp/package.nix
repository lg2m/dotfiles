{
  lib,
  fetchFromGitHub,
  python3Packages,
  aseprite,
}:
python3Packages.buildPythonApplication {
  pname = "aseprite-mcp";
  version = "0.10.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "MalloyTheDev";
    repo = "aseprite-mcp";
    tag = "v0.10.0";
    hash = "sha256-qhOejEYBrsN6YnUX14URG5oeil2gcXdOgX4qks/jRl4=";
  };

  build-system = [ python3Packages.hatchling ];
  dependencies = with python3Packages; [
    mcp
    pillow
    pydantic
  ];
  makeWrapperArgs = [
    "--set"
    "ASEPRITE_PATH"
    (lib.getExe aseprite)
  ];
  pythonImportsCheck = [ "aseprite_mcp.server" ];
  nativeCheckInputs = with python3Packages; [
    pytestCheckHook
    hypothesis
  ];
  pytestFlags = [
    "tests/test_unit.py"
    "tests/test_output_paths.py"
  ];

  meta = {
    description = "MCP server for editing Aseprite sprites through headless Lua scripting";
    homepage = "https://github.com/MalloyTheDev/aseprite-mcp";
    license = lib.licenses.mit;
    mainProgram = "aseprite-mcp";
    platforms = lib.platforms.linux;
  };
}
