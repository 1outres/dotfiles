{ ... }:

# GNOME only exports SSH_AUTH_SOCK for the gcr ssh-agent into the graphical
# session, so a shell opened over SSH or from herdr cannot reach the agent.
# systemd socket activates the agent, so the path is always there and every
# shell can point at it.

{
  home.sessionVariables.SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/gcr/ssh";
}
