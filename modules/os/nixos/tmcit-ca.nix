{ ... }:

# Root CA handed out by TMCIT (metro-cit.ac.jp) for its campus network. It is a
# self-signed certificate whose CN is the RADIUS host itself, so the only thing
# it is good for is verifying the server during 802.1X Wi-Fi login.
#
# The school's own instructions run update-ca-certificates, which would put it
# in security.pki.certificateFiles here. That is wider than it needs to be:
# every TLS client on the host would then accept anything this CA signs. The
# file is installed on its own instead, and the Wi-Fi profile points at it.
#
# It has to live under /etc because wpa_supplicant.service runs with
# ProtectHome=yes and only gets /etc and /nix/store bind-mounted in. A path in
# $HOME reads back as "No such file or directory" and PEAP fails to start.
#
# The matching NetworkManager profile needs:
#   802-1x.ca-cert=/etc/tmcit/nacacert.crt
#   802-1x.eap=peap
#   802-1x.phase2-auth=mschapv2
#   802-1x.domain-suffix-match=edu.metro-cit.ac.jp

{
  environment.etc."tmcit/nacacert.crt" = {
    source = ./tmcit-ca/nacacert.crt;
    mode = "0444";
  };
}
