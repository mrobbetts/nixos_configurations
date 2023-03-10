lib: {

  netmon = {
    autoStart = true;
    privateNetwork = true;
    hostBridge = "br0";

    config = { config, pkgs, ...}: {
/*
      networking = {
        interfaces."eth0".useDHCP = true;
        firewall = {
          enable = false;
          allowedTCPPorts = [ 80 443 ];
        };
      };
*/
      services = {
        grafana = {
          enable = true;
          protocol = "http";
          address = "0.0.0.0";        
        };
      };
    };
  };

}

/*
gitea = {
    autoStart = true;
    privateNetwork = true;
    hostBridge = "br0";

    config = { config, pkgs, ...}: {
      networking = {
        interfaces."eth0".useDHCP = true;
        firewall = {
          enable = false;
          allowedTCPPorts = [ 80 443 ];
        };
      };
      services = {
        gitea = {
          enable = true;
          stateDir = "/gitea";
          database = {
            password = "blah";
          };
          rootUrl = "https://gitea.variance.org.uk";
          ssh.enable = false;
          disableRegistration = true;
#          service = {
            requireSigninView = true;
 #         };
        };
      };
    };
  };
*/
