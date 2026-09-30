# Identity for zmeyer: data shared by NixOS, darwin and Home Manager modules.
# Pure data (no pkgs/config) so it can be imported anywhere.
{
  name = "zmeyer";
  fullName = "Zachary Meyer";
  email = "159225316+lg2m@users.noreply.github.com";

  # Per-forge commit emails, selected by repository path under
  # ~/Development/repos/<forge>/...
  gitIncludes = {
    "gitlab.com/syntiantall/" = "5631694-zmeyer@users.noreply.gitlab.com";
    "codeberg.org/" = "zmeyer@noreply.codeberg.org";
  };

  # Extra groups on NixOS (only applied if the group exists).
  groups = [
    "wheel"
    "docker"
    "video"
    "audio"
  ];
}
