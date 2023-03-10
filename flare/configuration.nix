# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  nixpkgs.config = {

    # For the weird rtl firmware problem [https://github.com/NixOS/nixpkgs/pull/28654].
    allowBroken = true;

    allowUnfree = true;
  };

  boot = {
    # Use the systemd-boot EFI boot loader.
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    zfs.enableUnstable = true;

    kernelPackages = pkgs.linuxPackages_latest;
    #kernelPackages = pkgs.linux_6_1_hardened;

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

  networking = {
    hostId = "3360cd9a"; # head -c 8 /etc/machine-id
    hostName = "flare";
    firewall.enable = false;
    nat.enable = false;

    useDHCP = true;
    useNetworkd = true;

    usePredictableInterfaceNames = true;

  };

  # Set your time zone.
  time.timeZone = "US/Pacific";




  # networking.hostName = "nixos"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  # time.timeZone = "Europe/Amsterdam";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkbOptions in tty.
  # };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;


  

  # Configure keymap in X11
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = {
  #   "eurosign:e";
  #   "caps:escape" # map caps to escape.
  # };

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.users.alice = {
  #   isNormalUser = true;
  #   extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  #   packages = with pkgs; [
  #     firefox
  #     thunderbird
  #   ];
  # };
  users = {
    mutableUsers = false;
    defaultUserShell = "${pkgs.zsh}/bin/zsh";

    users = { 
      # Hack. The package needs to be updated.
      radius = { 
        isSystemUser = true;
        group = "radius";
      };

      root = {
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
    };
  };

  programs = {
    fish = { enable = true; };
    #zsh = (import ./extras/programs/zsh.nix) { inherit pkgs; };
    zsh = {
      enable = true;
      autosuggestions.enable = true;
      interactiveShellInit = ''
        # Import our li'l git helper.
        source ${pkgs.zsh-git-prompt}/share/zsh-git-prompt/zshrc.sh

        # See these guys in ~/git/zsh-git-prompt/zshrc.sh
        ZSH_THEME_GIT_PROMPT_STAGED="%{$fg[green]%}%{»%G%}"
        ZSH_THEME_GIT_PROMPT_CHANGED="%{$fg[yellow]%}%{»%G%}"
        ZSH_THEME_GIT_PROMPT_AHEAD="%{↑%G%}"
        ZSH_THEME_GIT_PROMPT_SEPARATOR="::"
        ZSH_THEME_GIT_PROMPT_BRANCH="%{$fg_bold[white]%}"
        ZSH_THEME_GIT_PROMPT_STASHED="%{$fg_bold[white]%}%{⚑%G%}"
        ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[white]%}%{∉%G%}"

        # History
        source ${pkgs.zsh-history-substring-search}/share/zsh-history-substring-search/zsh-history-substring-search.zsh
        bindkey '^[[A' history-substring-search-up
        bindkey '^[[B' history-substring-search-down

        # Needed for any prompt substitution to work.
        setopt prompt_subst

        # Addition for direnv
        eval "$(${pkgs.direnv}/bin/direnv hook zsh)"
      '';
      syntaxHighlighting = {
        enable = true;
        highlighters = [ "main" "brackets" "pattern" ];
        styles = { # Copy fish config. I like fish.
          "builtin" = "fg=27";
          "command" = "fg=27";
          "alias" = "fg=27";
          "default" = "fg=39";
          "path" = "fg=39,underline";
          "unknown-token" = "fg=red,bold";
          "single-hyphen-option" = "fg=39";
          "double-hyphen-option" = "fg=39";
        };
      };
      promptInit = "PROMPT='[%n@%m %(!.%F{red}.%F{green})%~%f $(git_super_status)]%(!.#.$) '";
    };

    ssh = { startAgent = true; };
  };


  # List packages installed in system profile. To search, run:
  # $ nix search wget
  # environment.systemPackages = with pkgs; [
  #   vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #   wget
  # ];
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget
    screen
    git
    chrony
    mkpasswd
    which
    nftables
    nix-prefetch-scripts
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
    wireguard-tools
    bridge-utils
    minicom
    qemu
    sysbench
    iozone
    sysstat
    gptfdisk
    direnv
    nodejs
    jq
    tree
    sqlite
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;
  services = {
    openssh = {
      enable = true;
      permitRootLogin = "no";
      passwordAuthentication = false;
      kbdInteractiveAuthentication = false;
/*
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
      };
*/
    };
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?

}

