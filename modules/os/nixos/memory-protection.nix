{ ... }:

{
  # This host has no swap device (hardware-configuration.nix sets swapDevices
  # to an empty list). Without one the kernel cannot evict anonymous pages, so
  # under pressure it reclaims the text pages of running binaries and faults
  # them straight back in. Userland then stalls on disk while the kernel keeps
  # answering ICMP and completing TCP handshakes on its own — the machine still
  # pings, but sshd never gets far enough to send its banner. zram gives those
  # pages somewhere to go that is not the disk.
  zramSwap.enable = true;

  # systemd-oomd starts by default but logs "No swap; memory pressure usage
  # will be degraded" and then never acts, so nothing interrupted the 15 minute
  # stall on 2026-08-16. earlyoom decides on free memory alone, which works
  # whether or not there is swap.
  services.earlyoom = {
    enable = true;

    extraArgs = [
      # Killing any of these costs more than the stall does: without sshd or
      # the network daemons there is no way back into the machine.
      "--avoid"
      "^(systemd|systemd-.*|sshd|sshd-session|dbus-daemon|NetworkManager|netbird|tailscaled|containerd|dockerd)$"

      # The Tilt dev loop is what actually eats the memory: ten services
      # rebuilt in parallel, each with a Go compiler and a buildkit worker.
      # Naming them keeps the kill on the build instead of the kind control
      # plane or the desktop session.
      "--prefer"
      "^(go|compile|link|gopls|tilt|buildkitd|node|esbuild)$"
    ];
  };
}
