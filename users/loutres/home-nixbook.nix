{
  config,
  lib,
  pkgs,
  ...
}:

let
  fcitx5Remote = lib.getExe' pkgs.fcitx5 "fcitx5-remote";
in
{
  imports = [
    ./home.nix
    ../../modules/home/chena.nix
    ../../modules/home/google-chrome.nix
    ../../modules/home/onepassword.nix
    ../../modules/home/onepassword-autostart.nix
    ../../modules/home/ssh-away-agent.nix
    ../../modules/home/zen-browser.nix
    ../../modules/home/zen-browser-widevine.nix
  ];

  chena = {
    touchpad.scrollFactor = 0.5;
    displays.enable = true;

    clamshell = {
      switch = "Apple SMC power/lid events";
      output = "eDP-1";
    };

    # Tapping Cmd works like the Eisu and Kana keys on a Mac keyboard: left
    # turns Japanese input off and right turns it on.
    extraLua.input-method = ''
      hl.bind("SUPER + SUPER_L", hl.dsp.exec_cmd("${fcitx5Remote} -c"), { release = true })
      hl.bind("SUPER + SUPER_R", hl.dsp.exec_cmd("${fcitx5Remote} -o"), { release = true })
    '';
  };

  # wgpu tries Vulkan first, and the only Vulkan device it takes here is
  # lavapipe, which draws on the CPU and makes every animation slow. OpenGL
  # goes to the Asahi GPU.
  systemd.user.services.shoji-bar-4 = lib.mkIf (config.chena.shell == "shoji-bar-4") {
    Service.Environment = [ "WGPU_BACKEND=gl" ];
  };

  tmuxWheel.lines = 2;
}
