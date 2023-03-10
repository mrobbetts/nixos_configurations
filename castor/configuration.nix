# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{

  nix = {
    settings = {
      sandbox = true;
      trusted-users = [ "buildUser" ];
      max-jobs = 8;
      cores = 32;
      experimental-features = [ "nix-command" "flakes" ];
    };

#    useSandbox = true;
#    nixPath = [ "/nix" "nixos-config=/etc/nixos/configuration.nix" "nixpkgs-overlays=/etc/nixos/overlays" "ssh-config-file=/home/public/.ssh/id_ed25519" ];
#    nixPath = [ "/nix" "nixos-config=/etc/nixos/configuration.nix" "nixpkgs-overlays=/etc/nixos/overlays" ];
    nixPath = [ "/nix" "nixos-config=/etc/nixos/configuration.nix" ];
#    maxJobs = 8;
#    buildCores = 32;

#    trustedUsers = [ "buildUser" ];
  };

  nixpkgs.overlays = [
    (import ./overlays/nixos-rocm)
    (import ./overlays/dotfiles/rocm.nix)
    (import ./overlays/syng-nix-overlay)
#    (import /etc/nixos/overlays/personal)
    (import ./overlays/nixos_personal_overlay)
  ];

  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./nixos_extra_modules
  ];

  #containers = (import ./extras/containers.nix) lib;

  # ROCm
# hardware.opengl.enable = true;
# hardware.opengl.extraPackages = [ pkgs.rocm-opencl-icd ];

/*
  nbd = {
    enable = true;
    exports = [
      { name = "zram_nbd_gospel";
        size = "4G";
        type = "zram";
      }
      { name = "zram_nbd_page";
        size = "4G";
        type = "zram";
      }
    ];
  };
*/
  zramBlocks = {
    enable = true;
    devices = [
    {  type = "block";
       size = "4G";
       name = "zram_extra";
       owner = "root";
       group = "root";
    }
    ];
  };

/*
  zramBlocks = {
    enable = true;
    devices = [
      { type = "block";
        size = "4G";
        name = "zram_gospel";
        owner = "nbd";
        group = "nbd";
      }
#      {
#        type = "swap";
#        size = 1024;
#        prio = 10;
#      }
    ];
  };
*/

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    zfs.enableUnstable = true;

    kernelPackages = pkgs.linuxPackages_latest;
    #kernelPackages = pkgs.linuxPackages_4_20;
    #kernelPackages = pkgs.linuxPackages_testing;
    kernelParams = [ "console=ttyS1,115200n8" ];

    tmpOnTmpfs = true;

    supportedFilesystems = [ "zfs" ];

    kernel = {
      sysctl = {
        # if you use ipv4, this is all you need
        "net.ipv4.conf.all.forwarding" = true;

        # Override some changes from the hardened profile.
        #"net.ipv4.icmp_echo_ignore_broadcasts" = false;

        # If you want to use it for ipv6
        "net.ipv6.conf.all.forwarding" = true;
      };
    };
  };

  # Use the systemd-boot EFI boot loader.
#  boot.loader.systemd-boot.enable = true;
#  boot.loader.efi.canTouchEfiVariables = true;
  
#  boot.kernelPackages = pkgs.linuxPackages_latest;
##  boot.kernelPackages = pkgs.linuxPackages_testing;
#  boot.kernelParams = [ "console=ttyS1,115200n8" ];
#  boot.tmpOnTmpfs = true;

  systemd.network = {
    enable = true;
/*
    links = {
      "10-wan" = {
        matchConfig.MACAddress = "0c:c4:7a:e6:bf:7e";
        linkConfig.Name = "wan";
      };
      "11-lan" = {
        matchConfig.MACAddress = "0c:c4:7a:e6:bf:7f";
        matchConfig.Type = "!vlan";
        linkConfig.Name = "lan";
#        linkConfig.AllMulticast = true;
#        extraConfig = ''
#          #[Link]
#          Promiscuous = True
#        '';
      };
    };

    networks = {
      "10-wan" = {
        matchConfig = {
          Name = "wan";
        };
        DHCP = "yes";
        dhcpConfig = {
          ClientIdentifier="mac";
        };
      };

      "12-wireguard" = {
        matchConfig = {
          Name = "if_wg";
        };
        address = [ "10.2.4.1/24" ];
      };
    };

    # Wireguard stuffs
    netdevs = {
      "wgd0" = {
        netdevConfig = {
          Kind = "wireguard";
          Name = "if_wg";
        };
        wireguardConfig = {
          ListenPort = 51820;
          PrivateKeyFile = "/secrets/wireguard-keys/private";
        };
        wireguardPeers = [
          {
            wireguardPeerConfig = {
              AllowedIPs = [ "10.2.4.10/32" ];
              PublicKey = "d5/hBdpyqqE9MlEDATTMlKJmV8pFYMnbgPj06gtyegs=";
            };
          }
          {
            wireguardPeerConfig = {
              AllowedIPs = [ "10.2.4.11/32" ];
              PublicKey = "gwdSf1t8+AcJO9m6LXv+qzXcRST+CF5n8vPq9qMN4UM=";
            };
          }
        ];
      };
    };
*/
  };

  networking = {
    hostId = "00000001";
    hostName = "castor";
    firewall.enable = false;
    nat.enable = false;

    #nameservers = [ "127.0.0.1" ];

    useDHCP = false;
    useNetworkd = true;

    usePredictableInterfaceNames = true;

#    interfaces = {
#      "wan" = {
#        useDHCP = true;
#      };
#    };

    tc_cake = {
      "wan" = {
        disableOffload = true;
        shapeEgress = {
          #bandwidth = "12mbit";
          bandwidth = "900mbit";
          extraArgs = "nat ethernet metro ack-filter";
        };
/*
        shapeIngress = {
          bandwidth = "801mbit";
          ifb = "ifb0";
        };
*/
      };
    };

    siteNetwork = {
      enable = true;
      siteName = "lan";
      networkDefs = rec {

        ipBase = "2"; # Contribute the unique network IP base, as N in "10.N.0.0".
/*
        mDNSReflectors = with networks; [
          { inherit trusted; inherit IoT; }
          { inherit local;   inherit IoT; }
          #{ inherit local;   inherit trusted; }
        ];
*/
        networks = rec {

          # Physical interfaces (match to MAC addresses).
          wan = {
            description = "The HW WAN uplink.";
            kind = "eth";
            macAddress = "0c:c4:7a:e6:bf:7e";

            networkdNetworkExtras = {
              dhcpConfig = {
                ClientIdentifier = "mac";
              };
              DHCP = "yes";
            };

          };

          mgmt = {
            description = "A partially isolated network for infra.";
            kind = "vlan";
            vid = 2;
            ip  = 2;
            mayInitiateWith = { inherit trusted;
                                inherit wan; };
          };
          cameras = {
            description = "An isolated network for cameras.";
            kind = "vlan";
            vid = 3;
            ip  = 3;
            mayInitiateWith = { };
          };
          guest = {
            description = "A wan-only network for guests.";
            kind = "vlan";
            vid = 11;
            ip  = 11;
            mayInitiateWith = { inherit wan; };
          };
          trusted = {
            description = "The trusted network; access to most things.";
            kind = "vlan";
            vid = 10;
            ip  = 10;
            mayInitiateWith = { inherit guest;
                                inherit mgmt;
                                inherit cameras;
                                inherit wan; };
          };
          IoT = {
            description = "A partially isolated network for IoT devices.";
            kind = "vlan";
            vid = 12;
            ip  = 12;
            mayInitiateWith = { };
          };

          lan = {
            description = "The HW interface carrying the internal VLANs.";
            kind = "eth";
            macAddress = "0c:c4:7a:e6:bf:7f";
            #ipAddress = "10.2.1.1/24";

            vlans = {
              inherit mgmt;
              inherit cameras;
              inherit guest;
              inherit trusted;
            };

            networkdNetworkExtras = {
              networkConfig = {
                LinkLocalAddressing = "no";
                LLDP = "no";
                EmitLLDP = "no";
                IPv6AcceptRA = "no";
                IPv6SendRA = "no";
              };
              linkConfig = {
                # Needed because this interface has no IP address, and will
                # not be considered "online" by default (which makes the
                # overall network online state show as "partial").
                RequiredForOnline = "carrier";
              };
            };
          };


          # Wireguard interfaces
          vpn = {
            kind = "wireguard";
            address = [ "10.2.4.1/24" ];
            listenPort = 51820;
            privateKeyFile = "/secrets/wireguard-keys/private";
            peers = [
              {
                wireguardPeerConfig = {
                  AllowedIPs = [ "10.2.4.10/32" ];
                  PublicKey = "d5/hBdpyqqE9MlEDATTMlKJmV8pFYMnbgPj06gtyegs=";
                };
              }
              {
                wireguardPeerConfig = {
                  AllowedIPs = [ "10.2.4.11/32" ];
                  PublicKey = "gwdSf1t8+AcJO9m6LXv+qzXcRST+CF5n8vPq9qMN4UM=";
                };
              }
            ];
          };

          ###
/*
          # Physical lan0 interface.
          local = {
            vid = 13;
            ip  = 13;
#            interface = "lan";
            hasInternetAccess = true;
            mayInitiateWith = { inherit IoT; inherit trusted; inherit mgmt; };
            isVLAN = true;
          };

          # Management, VLAN
          mgmt = {
            vid = 2;
            ip  = 2;
#            interface = "lan";
            hasInternetAccess = true;
            mayInitiateWith = { inherit IoT; inherit trusted; inherit local; };
            isVLAN = true;
          };

          cameras = {
            vid = 3;
            ip  = 3;
            hasInternetAccess = false;
            mayInitiateWith = { };
            isVLAN = true;
          };

          #IoT VLAN; restricted local access.
          IoT = {    # No internet access; non-L2 isolated; can only be initiated against.
            vid = 12;
            ip  = 12;
#            interface = "lan";
            hasInternetAccess = true; # TEMP. For the Cells.
            mayInitiateWith = {};
            isVLAN = true;
          };

          guest = {   # WAN access; L2-isolated; mDNS reflection? "Guest" network.
            vid = 11;
            ip  = 11;
#            interface = "lan";
            hasInternetAccess = true;
            mayInitiateWith = {};
            isVLAN = true;
          };

          # Trusted vlan. Access to everything except mgmt.
          trusted = {
            vid = 10;
            ip  = 10;
#            interface = "lan";
            hasInternetAccess = true;
            mayInitiateWith = { inherit IoT;
                                inherit guest;
                                inherit local;
                                inherit mgmt;
                                inherit cameras; };
            isVLAN = true;
          };
*/
        };
      };
    };

    #useDHCP = false;
    #useNetworkd = true;
  };

#    useDHCP = false;
#    useNetworkd = true;
#  };

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_US.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "US/Pacific";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget
    screen
    git
#    gcc
#    llvm
    chrony
    mkpasswd
    which
    nftables
    nix-prefetch-scripts
#    python
#    emacs
    htop
    lm_sensors
    ipmitool
    smartmontools
    lshw
    pciutils
    dnsutils
    nmap
    iptraf-ng
    net-snmp
#    elfutils
#   glxinfo
    wireguard-tools
    bridge-utils
    minicom
    qemu
    sysbench
    iozone
    sysstat
#   unrar
#    opencl-info
#    rocminfo
#    xmr-stak
    gptfdisk
    direnv
    nodejs
    jq
    tree
    sqlite
    texlive.combined.scheme-medium
#    texlive.combine {
#      inherit (texlive) scheme-basic xelatex collection-langkorean algorithms cm-super;
#    }
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.bash.enableCompletion = true;
  # programs.mtr.enable = true;
  # programs.gnupg.agent = { enable = true; enableSSHSupport = true; };

  programs = {
    fish = { enable = true; };
    zsh = (import ./extras/programs/zsh.nix) { inherit pkgs; };
    ssh = { startAgent = true; };
  };

  # List services that you want to enable:
  services = {
    smartd = { enable = true; };
    eternal-terminal = { enable = true; };
    openssh =   (import ./extras/services/openssh.nix);
    syncthing = (import ./extras/services/syncthing.nix);
#    monero =    (import ./extras/services/monero.nix);
    xmr-stak =  (import ./extras/services/xmr-stak.nix { inherit pkgs; });
    jack =      (import ./extras/services/jack.nix { inherit pkgs; });

    freeradius = { enable = true; };

    nginx = {
      enable = true;
      virtualHosts = {
        localhost = {
          #forceSSL = true;
          #sslCertificate = "/var/lib/acme/syncthing.variance.org.uk/fullchain.pem";
          #sslCertificateKey = "/var/lib/acme/syncthing.variance.org.uk/key.pem";
          root = "/var/lib/www/";
          listen = [{
            addr = "10.2.2.1";
            port = 80;
          }];
/*
          locations = {
              "/.well-known/acme-challenge" = {
                root = "/var/www/challenges/";
              };
              "/" = {
                proxyPass = "http://127.0.0.1:8384";
                extraConfig = ''
                  auth_basic "Restricted";
                  auth_basic_user_file /var/www/htpasswd;
                '';
              };
            };
          };
*/
        };
      };
    };

    chrony = {
      enable = true;
      #extraFlags = [ "-x" ]; "-x" prevents it from updating the HW clock.
      extraConfig = ''
        allow
      '';
    };
    sanoid = {
      enable = true;
      templates = {
        primary = {
          yearly = 5;
          monthly = 12;
          daily = 60;
          hourly = 30;
          autoprune = true;
          autosnap = true;
        };
      };
      datasets = {
        "rpool2/syncthing/Personal" = {
          useTemplate = [ "primary" ];
        };
      };
    };
/*
    shinobi = {
      enable = false;
      superUsers = [
        { mail = "admin@shinobi.video";    pass = "21232f297a57a5a743894a0e4a801fc3"; }
        { mail = "wingfeathera@gmail.com"; pass = "6f1ed002ab5595859014ebf0951522d9"; }
      ];
      settings = {
        port = 8081;
        databaseType = "sqlite3";
      };
    };
*/
    shinobi = {
      enable = true;
      superUsers = [
        #{ mail = "admin@shinobi.video";    pass = "21232f297a57a5a743894a0e4a801fc3"; }
        { mail = "wingfeathera@gmail.com"; pass = "6f1ed002ab5595859014ebf0951522d9"; }
      ];
      settings = {
        databaseType = "sqlite3";
        #ip = "10.2.10.1";
        #port = 8081;
        ip = "10.2.3.1";
        port = 80;
      };
    };

    samba = {
      enable = true;
      extraConfig = ''
        bind interfaces only = yes
        interfaces = lo vl_trusted
      '';
      shares = {
        tm_share = {
          path = "/home/mrobbetts/";
          "valid users" = "mrobbetts";
          public = "no";
          writeable = "yes";
          #"force user" = "username";
          "fruit:aapl" = "yes";
          "fruit:time machine" = "yes";
          "vfs objects" = "catia fruit streams_xattr";
        };
      };
    };

    kubo = {
      enable = true;
      settings = {
        Bootstrap = [
          "/ip4/192.168.1.81/tcp/4001/p2p/12D3KooWQAL4asmgTKL1QVecKieycq2yUwNmAj9ri6Enp6N5N9AG"
        ];
        Datastore.StorageMax = "100GB";
        Addresses.API = "/ip4/0.0.0.0/tcp/5001";
        Addresses.Gateway = "/ip4/0.0.0.0/tcp/8080";
        Swarm.AddrFilters = [];
      };
    };

    jupyter = {
      enable = true;
      ip = "0.0.0.0";
      password = "'sha1:1773c02d199a:38a044d0ae63132ec126d4de6f3fa43a013ce7cf'";
      kernels = {
        python3 = let
          env = (pkgs.python3.withPackages (pythonPackages: with pythonPackages; [
                  ipykernel
                  #pandas
                  #scikitlearn
                  matplotlib
                  numpy
                  scipy
                ]));
        in {
          displayName = "Python 3 with extras";
          argv = [
            "''${env.interpreter}"
            "-m"
            "ipykernel_launcher"
            "-f"
            "{connection_file}"
          ];
          language = "python";
          #logo32 = "''${env.sitePackages}/ipykernel/resources/logo-32x32.png";
          #logo64 = "''${env.sitePackages}/ipykernel/resources/logo-64x64.png";
        };
      };
    };
    /* Grafana stuff... */
    grafana = {
      enable = false;
      settings = {
        server = {
          protocol = "http";
          http_addr = "0.0.0.0";
        };
        security = {
          admin_user = "admin";
          admin_password = "blah";
        };
        users = {
          allow_sign_up = false;
        };
        "auth.google" = {
          allow_sign_up = false;
        };
      };
      #protocol = "http";
      #addr = "0.0.0.0";
      #security = {
      #  adminUser = "admin";
      #  adminPassword = "blah";
      #};
      #users = {
      #  allowSignUp = false;
      #};
      #auth = {
      #  google.allowSignUp = false;
      #};
      provision = {
        enable = true;
        datasources = [
        { name = "Prometheus (node)";
          access = "proxy";
          url = "http://localhost:9090";
          type = "prometheus";
        }
/*
        { name = "Prometheus (openLDAP)";
          access = "proxy";
          url = "http://localhost:9330";
          type = "prometheus";
        }
        { name = "Prometheus (smartctl)";
	  access = "proxy";
          url = "http://localhost:9633";
          type = "prometheus";
        }
        { name = "Prometheus (kea)";
          access = "proxy";
          url = "http://localhost:9547";
          type = "prometheus";
        }
*/
        ];
      };
    };
/*
    prometheus = {
      enable = false;
      exporters = {
        node = {
          enable = true;
          enabledCollectors = [ "systemd" ];
          #port = 9002;
        };
        bind = {
          enable = true;
        };
///*
        openldap = {z
          enable = true;
          #ldapCredentialFile = "/etc/raddb/users";
          ldapCredentialFile = writeFile '''
            #server: tcp:port=9142
            #client: tcp:host=127.0.0.1:port=389
            binddn: cn=Manager,dc=example,dc=com
            bindpw: FortyThousandBees
          '''
        };
//
        smartctl = {
          enable = true;
        };
        kea = {
          enable = true;
          controlSocketPaths = [ "/run/kea/kea-dhcp4.socket" ];
        };
      };
      scrapeConfigs = [{
        job_name = "chrysalis";
        static_configs = [{
          targets = [
            "127.0.0.1:${toString config.services.prometheus.exporters.node.port}"
            "127.0.0.1:${toString config.services.prometheus.exporters.smartctl.port}"
            "127.0.0.1:${toString config.services.prometheus.exporters.bind.port}"
            "127.0.0.1:${toString config.services.prometheus.exporters.kea.port}"
          ];
        }];
      }];

    };
    // End Grafana stuff... /
*/
  };

    sound = {
      enable = true;
      extraConfig = ''
        defaults.pcm.!card "Babyface2312334"
        defaults.ctl.!card "Babyface2312334"
      '';
    };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.extraUsers.guest = {
  #   isNormalUser = true;
  #   uid = 1000;
  # };
  users = {
    mutableUsers = false;
    defaultUserShell = "${pkgs.zsh}/bin/zsh";
    extraUsers = {
      root = {
        #shell = "${pkgs.fish}/bin/fish";
        hashedPassword = "$6$1EqKSFYsQhE27Z$QASI5z7L7hqF8aOvoAbe9.GDuheY46CBuK8F4hkpTksKuQb6cgBCIrwwAhI4VZLm2fxRJmgfpEhoMI4CVVm75.";
#        extraGroups = [ "jackaudio" ];
      };
      qoli = {
        isNormalUser = true;
        description = "qoli";
        extraGroups = [ "wheel" "networkmanager" "video" ];
        openssh.authorizedKeys.keys = [
#          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCi9kiHENun0YvdAlF+frq660jwVFt7d3txHOA1EkOs8S1NdUA532kocPxOMigKqi7hvBdPyxCIRS+eaeahR/sKvXHQxqElrUSW+oTJn9XjxPRs3LqHE4vfUJkwssZUaKi2YZsCCvGLaAc7cvn7tFekvmAGpbevJXWD2/sDYTVZhGZ9RiXqHdHbcUInCkCk8BVzvDNY+bqevhgjW+5CZZGAZfZ0oJrWADI/K8TGYYqYGKiikgwhV4ARVbRQrnyGwU8diGSKMb9TZAh/sNrPWXfa5m7KMAbEFEgEOjWxZsEmTDZbsLPlKSnLh07BOz3XTksozwkTxLpJTAY5ZAWGLp9/ mrobbetts@mrobbetts-mbp"
#          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCx26bxdZKxVJAW8h7+Fw3mlSGdHLugaAuTS5AjuzXCeg2omkar3+6R5AAF8DR6eGNTgDtrpgpayjR1p7I1akLaLyHJkve9lCJLkw8FLvxTwFHDPjpkr+uFdqAyYdQgb9JXLZ0tnaZvnCaIEMx3E3+dlXDs3eHkE4nUaDltTLs35tgLyh12ZPaeuJ2YbWuOYUmL25XSmfSXyUVN4bmjL+qlsff7fn5M594KUO+hP1rlQD6lqg0d8DwdVQtoQmTBZ/WjwZe9dZGE/HOMj5LG4+vSfgGo15oHaOM/VmVDB1qk4EWHELgihd1hhxPqw/UKJse1oBSci5OZVFIsGbw18A0L wingfeather@copper"
#          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQD3JRPUL/PsFAS1d6C8dbL95Qv8spSMbhPo/Mf6ovNuwir1mtRSLh5djwHPNNu3uS0sSrjUYNq1L3hOdiU+zMUVDTbgOY/jWubTU5uux2/Y8yvhpXjqjomSLJrzTvmiC4/uUJryyx4BOWRwMGN2fvcqEIoNtfnFO+HmmY9qzXvBLEWl6/eVyuXRRFoRWo2aF1EgWVfpnssRwE0LdtfVLfFCFBkcH5l4eLkIJj0HcqhwuGWsc3xw+6PYyH8+mc9PDNsjU7kCSkGnugS7FU2jxmKxBwtuSPVHQmrRl/miGjrFSfkrMONBEfaYjPd2eYQXaOGZygFvcYa5eVaidsXZSa8nh8B+PLFgcVf9MWIevlBc+6SY9NPIEWj96joNyZD3x4WwTZvx4aKuNOj5/dIC9K47FJ2wJrEfGKft1hMbB6AwoO0ItQXXc0UGPtUMc4C04ltAPxFrUCAStbLvSHKptgdamX4Nmrpyadv8iFQo2LI3cAsNMIuQU41fi4G8VrUXUlocedt0McmI8vnNSa6O3ix4GQdDtsg/1FVrJWufJP+8pu/J1tCnKQXCTNrfDKA0kzch0JMHaFCBxVeySgB8EL6wv/+wMeskHyp2uPEugiBNVEjPktibwRSMB0pDPTeB70fAyDfmJeRlRwQxKvvDpmzHNamNvPRZDXNVLXbKJjhNBQ== mrobbetts@Matthews-MBP.local"
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDA9q1lh8tYk3PwjUg5yAWPgwgB0F0wBDNoIrjjhysp2EdvhUNmMKIy4n4U2Kc9Z/UuBKBRRWWphbZrNHENeu4BDbdryH3nHRJ/fl2OcKVezt/VdILO6Ft+SxdwqfL+UScgCzZfg66d6yot7rb0uyktIf4R8FgCqetzi0eX+dw0HHBpo0hSZQTnEf7tU4s3rEGnc1hWpJm5DBFEeFM/TMfrnfXpSzhgZiptH+Pn52FVIERYk1jI3+8tdxnpeF7Y/KQs2OYVDj+aa6HAwUFkz+CusKFHZgcVYfHTDQMnJ+WfCrSGTVo/Vd4nH06oyUaymf9IlchuTiiirJKER1ia5Gxt wingfeather@braid"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILNs/l02pd8neW1SGE+gnZY1/byy4gaUFyWHKaUvtNID mrobbetts@chaff"
        ];
        hashedPassword = "$6$1EqKSFYsQhE27Z$QASI5z7L7hqF8aOvoAbe9.GDuheY46CBuK8F4hkpTksKuQb6cgBCIrwwAhI4VZLm2fxRJmgfpEhoMI4CVVm75.";
      };
      mrobbetts = {
        isNormalUser = true;
        extraGroups = [ "wheel" "jackaudio" "audio" ];
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILNs/l02pd8neW1SGE+gnZY1/byy4gaUFyWHKaUvtNID mrobbetts@chaff"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC7r6KSgW8Xlq6mJnbC9H91puJfU86q4hhTVPf3WHt3L mrobbetts@riffraff"
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDA9q1lh8tYk3PwjUg5yAWPgwgB0F0wBDNoIrjjhysp2EdvhUNmMKIy4n4U2Kc9Z/UuBKBRRWWphbZrNHENeu4BDbdryH3nHRJ/fl2OcKVezt/VdILO6Ft+SxdwqfL+UScgCzZfg66d6yot7rb0uyktIf4R8FgCqetzi0eX+dw0HHBpo0hSZQTnEf7tU4s3rEGnc1hWpJm5DBFEeFM/TMfrnfXpSzhgZiptH+Pn52FVIERYk1jI3+8tdxnpeF7Y/KQs2OYVDj+aa6HAwUFkz+CusKFHZgcVYfHTDQMnJ+WfCrSGTVo/Vd4nH06oyUaymf9IlchuTiiirJKER1ia5Gxt wingfeather@braid"
        ];
        hashedPassword = "$6$1EqKSFYsQhE27Z$QASI5z7L7hqF8aOvoAbe9.GDuheY46CBuK8F4hkpTksKuQb6cgBCIrwwAhI4VZLm2fxRJmgfpEhoMI4CVVm75.";
      };
      buildUser = {
        isNormalUser = true;
        description = "Just for building";
        openssh.authorizedKeys.keys = [ 
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDuT1kTxKVnnerCX2urUttLss3D5ll03rGUhGZjH0ubwWTSPmISaFCPj4xwerg22uH1VUQ1JI3+oCebOWaBKANLqakKWGXtxqnNp97NYVrCRqRlOAsHYLLyK1tHbalBoXM5A/rvXj2LmjjVHCnjqoVJPWeettziq5p3AMmvNmSI2+zUCtDdERGeWj0MnqjxbmTSItfNa8Vp7dfV99LgqzQN4C9JFystu/xH2XepB6DvfcMcFkBKkcJ+RbOWaPUfouGRRPXuxjr/4Smo7CwIp8u3kQ8uM7LKVzHegurZd1yi+v6nP20qzPArt2mqMYn+16vwCbfrEzfkKc+dEwjGPKMv root@braid"
        ];
      }; 

      jupyter = {
        group = "jupyter";
#        isNormalUser = true;
        description = "Jupyter user? Unsure why this is needed.";
      };

    };

    # Hack. The package needs to be updated.
    users = { 
      radius = { 
        isSystemUser = true;
        group = "radius";
      };
    };
  };

  nixpkgs.config = {

    # For the weird rtl firmware problem [https://github.com/NixOS/nixpkgs/pull/28654].
    allowBroken = true;
    allowUnfree = true;

    # This carrazy "let self = ... in self;" structure seems to be needed for the libressl override to work. Thanks joachifm! [https://github.com/NixOS/nixpkgs/issues/28302]
    packageOverrides = pkgs: rec {

      # LibreSSL override needs this fetchurl override internally... for some reason.
#      openssl = pkgs.libressl_2_8.override { fetchurl = pkgs.stdenv.fetchurlBoot; };
#      openssl = pkgs.libressl_2_9;

#      nghttp2 = pkgs.nghttp2.override { openssl = pkgs.libressl_2_9.override { fetchurl = pkgs.stdenv.fetchurlBoot; }; };
/*
      nghttp2 = (pkgs.nghttp2.override { openssl = pkgs.libressl_2_8.override { fetchurl = pkgs.stdenv.fetchurlBoot; }; }).overrideAttrs (attrs: {
        patches = [
          (pkgs.stdenv.fetchurlBoot {
            url = "https://patch-diff.githubusercontent.com/raw/nghttp2/nghttp2/pull/1270.patch";
            sha256 = "0wixqg0crazdrr51ij2rq0wdxr11kaldnw571qyidhslc73pfd5c";
          })
        ];
      }); 
*/
#      serf = pkgs.serf.override { openssl = pkgs.openssl; };

#      libgit2 = pkgs.libgit2_0_27;
    };
  };


  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "18.03"; # Did you read the comment?

}

