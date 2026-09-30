{
  lib,
  fetchFromGitHub,
  python3Packages,
  aseprite,
}:
# Upstream imports FastMCP, which was removed in MCP SDK 2.x.
assert lib.versionOlder python3Packages.mcp.version "2";
python3Packages.buildPythonApplication {
  pname = "aseprite-mcp";
  version = "0.7.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "MalloyTheDev";
    repo = "aseprite-mcp";
    rev = "8caabf9ce240a040ca2c94d3d7366c9d8dd63653";
    hash = "sha256-O+YhJsoo1sHoPBFuS8+hit2jYDhs3zS8GRfKhoYxvYg=";
  };

  build-system = [ python3Packages.hatchling ];
  dependencies = with python3Packages; [
    mcp
    pillow
  ];
  postPatch = ''
    substituteInPlace pyproject.toml --replace-fail 'mcp[cli]>=1.4.0' 'mcp[cli]>=1.4.0,<2'
  '';
  makeWrapperArgs = [ "--set ASEPRITE_PATH ${lib.getExe aseprite}" ];
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
