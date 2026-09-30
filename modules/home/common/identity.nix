# Who the Home Manager user is. Set by users/<name>/home.nix; read by
# git, jj and anything else that needs a name/email.
{ lib, ... }:
{
  options.my.identity = {
    fullName = lib.mkOption {
      type = lib.types.str;
      description = "Full name used for commits.";
    };
    email = lib.mkOption {
      type = lib.types.str;
      description = "Default commit email.";
    };
    gitIncludes = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      example = {
        "codeberg.org/" = "me@noreply.codeberg.org";
      };
      description = ''
        Map of repository path prefixes (relative to
        ~/Development/repos/) to the commit email used there.
      '';
    };
  };
}
