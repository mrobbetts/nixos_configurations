let
  riffraff = {
    #name = "riffraff";
    id = "OA4HMI3-ANGW7DA-NFW7TLA-FIG6DEF-X3L5XFN-4XL6WGH-DU5J6IQ-KTJJMQ5";
  };
  castor = {
    #name = "castor";
    id = "5THYONA-PRVBPG5-BBCHBEV-IBNVCP4-BP4D2EF-JP5JKQP-5JWE3FM-IVU6SAR";
  };
  braid = {
    #name = "braid";
    addresses = [ "tcp://variance.org.uk" ];
#    id = "535ZENG-474JFFP-YT3DEJV-A63746K-UTZHVHJ-Y4NAQEG-5KPFJEP-H4ZZ2AL";
    id = "HFOJOM3-X6IU4PV-UV7BVNF-ZQ7QH5P-6PAUZL7-7ZC2N76-6OZITYT-4K22OQI";
  };

#  "/var/lib/syncthing/Personal" = {
  "~/Personal" = {
    id = "wzvgx-gmkzd";
    label = "Personal";
    devices = [ "riffraff" "braid" ];
  };

in
{
  enable = true;
#  user = "qoli";
#  group = "users";
  #guiAddress = "0.0.0.0:8384";
  guiAddress = "10.2.10.1:8384";
#  dataDir = "/home/qoli/.syncthing";

  overrideDevices = true;
  devices = {
    inherit riffraff;
    inherit braid;
  };

  overrideFolders = true;
  folders = {
#    inherit "/var/lib/syncthing/Personal";
    inherit "~/Personal";
  };

}
