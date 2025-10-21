# TODO: remove?

{ ... }:
let
  email = "9l@9lo.re";
  ghName = "ninelore";
  name = "Ingo Reitz";
in
{
  programs.git = {
    signing = {
      signByDefault = true;
      key = "794BE2582FB7A351"; # TODO decouple from config somehow?
    };
    settings.github.user = ghName;
    settings.user = {
      inherit email name;
    };
  };
}
