{ ... }:

{
  # The guest shares 32GB of physical RAM with the macOS host. Reclaiming
  # dentry/inode caches more eagerly returns pages to macOS via OrbStack's free
  # page reporting, which keeps the host out of swap while the VM is idle.
  boot.kernel.sysctl = {
    "vm.vfs_cache_pressure" = 200;
  };
}
