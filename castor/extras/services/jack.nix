{ pkgs }:
{
  jackd = {
    enable = false;
    extraOptions = [ "-d" "alsa" "--device" "hw:1" "-n" "master" ];
#    package = pkgs.syngjack2.override { dbus = pkgs.dbus; };
    package = pkgs.syngjack2;
  };
}
