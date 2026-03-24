# TODO: remove?

{ ... }:
let
  email = "9l@9lo.re";
  ghName = "ninelore";
  name = "Ingo Reitz";
in
{
  programs.git = {
    # settings.github.user = ghName;
    settings.user = {
      inherit email name;
    };
  };
}
