{ pkgs, ... }:

# Raycast-like launcher. The companion GNOME extension is what makes the
# clipboard history work at all: Mutter implements neither ext-data-control-v1
# nor wlr-data-control, so nothing outside the compositor can observe a copy.
# The extension watches the clipboard from inside GNOME Shell, hands the events
# to the server over D-Bus, and pastes a picked entry into the window that had
# focus. https://docs.vicinae.com/quickstart/gnome

let
  vicinae = "${pkgs.vicinae}/bin/vicinae";

  customKeybindingPath = "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings";
in
{
  imports = [ ./dconf-reload.nix ];

  home.packages = [ pkgs.vicinae ];

  programs.gnome-shell = {
    enable = true;
    extensions = [ { package = pkgs.gnomeExtensions.vicinae; } ];
  };

  # Mirrors the unit shipped in the package. Declaring it here keeps the service
  # in the same place as the keybindings that depend on it.
  systemd.user.services.vicinae = {
    Unit = {
      Description = "Vicinae launcher daemon";
      Documentation = [ "https://docs.vicinae.com" ];
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Service = {
      ExecStart = "${vicinae} server --replace";
      Restart = "always";
      RestartSec = 5;
    };

    Install.WantedBy = [ "graphical-session.target" ];
  };

  dconf.settings = {
    # The window class is matched case-insensitively as a substring, so this one
    # entry covers every 1Password window.
    "org/gnome/shell/extensions/vicinae".blocked-applications = [ "1Password" ];

    "${customKeybindingPath}/custom0" = {
      name = "Vicinae";
      command = "${vicinae} toggle";
      binding = "<Super>space";
    };

    "${customKeybindingPath}/custom1" = {
      name = "Vicinae clipboard history";
      command = "${vicinae} deeplink vicinae://launch/clipboard/history";
      binding = "<Alt>space";
    };

    "org/gnome/settings-daemon/plugins/media-keys".custom-keybindings = [
      "/${customKeybindingPath}/custom0/"
      "/${customKeybindingPath}/custom1/"
    ];

    # Both shortcuts are taken by GNOME defaults. Only the Super/Alt spellings
    # are dropped; the dedicated keyboard key keeps switching input sources.
    "org/gnome/desktop/wm/keybindings" = {
      switch-input-source = [ "XF86Keyboard" ];
      switch-input-source-backward = [ "<Shift>XF86Keyboard" ];
      activate-window-menu = [ ];
    };
  };
}
