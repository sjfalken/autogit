{
  lib,
  python3Packages,
}:

python3Packages.buildPythonApplication {
  pname = "autogit";
  version = "0.1.0";
  pyproject = true;

  src = ../../scripts/autogit;

  build-system = [ python3Packages.setuptools ];

  dependencies = [ python3Packages.anthropic ];

  meta = {
    description = "Auto git commit message generator using Claude";
    license = lib.licenses.mit;
    mainProgram = "autogit";
  };
}
