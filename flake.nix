{
  description = "";

  inputs = {
  };

  outputs =
    {
      self,
      ...
    }@inputs:
    let
    in
    {
      devenvModules.autogit = ./devenv-modules/autogit.nix;
    };
}
