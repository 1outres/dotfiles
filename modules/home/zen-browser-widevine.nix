{ pkgs, ... }:

let
  lockedPref = value: {
    Value = value;
    Status = "locked";
  };
in
{
  # Mozilla serves no Widevine CDM for Linux on ARM, so Zen never downloads one
  # and DRM sites such as Spotify cannot play. This hands Zen the CDM that
  # Google ships with Chrome instead.
  programs.zen-browser = {
    env.MOZ_GMP_PATH = "${pkgs.widevine-cdm}/gmp-widevinecdm/system-installed";

    policies.Preferences = {
      "media.eme.enabled" = lockedPref true;
      "media.eme.encrypted-media-encryption-scheme.enabled" = lockedPref true;
      "media.gmp-widevinecdm.autoupdate" = lockedPref false;
      "media.gmp-widevinecdm.enabled" = lockedPref true;
      "media.gmp-widevinecdm.version" = lockedPref "system-installed";
      "media.gmp-widevinecdm.visible" = lockedPref true;
    };
  };
}
