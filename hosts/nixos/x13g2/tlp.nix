{ ... }:

# TLP takes over from power-profiles-daemon on this host. Both write the same
# knobs and systemd marks them as conflicting, so only one of them can run.
#
# power-profiles-daemon only sets the CPU energy-performance hint and the ACPI
# platform profile. TLP sets those too, and on top of that it lets the PCIe
# links, the idle Realtek NIC and the Wi-Fi radio go to sleep, which is where
# most of the remaining idle draw sits.
#
# The price is the power mode switcher in the GNOME menu. It reads
# power-profiles-daemon over D-Bus, so it has nothing left to show.

{
  # The GNOME module in nixpkgs turns this on. TLP refuses to start while it
  # is running.
  services.power-profiles-daemon.enable = false;

  services.tlp = {
    enable = true;

    settings = {
      # amd-pstate runs in EPP mode here. The governor only picks the ceiling,
      # and the energy-performance hint below does the real work.
      CPU_DRIVER_OPMODE_ON_AC = "active";
      CPU_DRIVER_OPMODE_ON_BAT = "active";

      CPU_SCALING_GOVERNOR_ON_AC = "powersave";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
      # "power" is the next step down, but it holds the cores close to their
      # base clock and makes the desktop feel slow, so battery stops here.
      CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";

      # Boost stays on. A short burst finishes sooner and lets the package fall
      # back into a deep idle state, which beats stretching the same work out
      # at the base clock.
      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 1;

      # The embedded controller's own budget. "low-power" lowers the sustained
      # package power, which the energy-performance hint alone cannot reach.
      PLATFORM_PROFILE_ON_AC = "balanced";
      PLATFORM_PROFILE_ON_BAT = "low-power";

      # The built-in Realtek NIC stays fully powered with no cable attached
      # unless runtime PM is allowed to suspend it, so this is on for AC too.
      RUNTIME_PM_ON_AC = "auto";
      RUNTIME_PM_ON_BAT = "auto";

      PCIE_ASPM_ON_AC = "default";
      PCIE_ASPM_ON_BAT = "powersupersave";

      WIFI_PWR_ON_AC = "off";
      WIFI_PWR_ON_BAT = "on";
    };
  };
}
