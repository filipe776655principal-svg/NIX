{ config, pkgs, lib, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;


# kernel config
  #boot.kernelPackages = pkgs.linuxKernel.packages.linux_xanmod_latest; #xan
  boot.kernelPackages = pkgs.linuxPackages_testing; # mainline
  #boot.kernelPackages = pkgs.linuxPackages_latest; # stable

# ---

  networking.hostName = "NIX-BTW"; # HOST

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Sao_Paulo";

  # Select internationalisation properties.
  i18n.defaultLocale = "pt_BR.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pt_BR.UTF-8";
    LC_IDENTIFICATION = "pt_BR.UTF-8";
    LC_MEASUREMENT = "pt_BR.UTF-8";
    LC_MONETARY = "pt_BR.UTF-8";
    LC_NAME = "pt_BR.UTF-8";
    LC_NUMERIC = "pt_BR.UTF-8";
    LC_PAPER = "pt_BR.UTF-8";
    LC_TELEPHONE = "pt_BR.UTF-8";
    LC_TIME = "pt_BR.UTF-8";
  };

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;
 
#   INTERFACE GRAFICA CONFIGURAÇOES #
	
  # GNOME
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  services.gnome.core-apps.enable = false;

# extensions / ricing

environment.loginShellInit = ''
  # workspace
  ${pkgs.dconf}/bin/dconf write /org/gnome/mutter/dynamic-workspaces false
  ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/wm/preferences/num-workspaces 1
  # wallpaper
  ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/background/picture-uri "'file:///home/filipe/wallpapers/NIX-WALLPAPER.png'"
  ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/background/picture-uri-dark "'file:///home/filipe/wallpapers/NIX-WALLPAPER.png'"
'';


  programs.dconf.enable = true;

  programs.dconf.profiles.user.databases = [
    {
      settings = {
        "org/gnome/shell/extensions/dash-to-dock" = {
          always-center-icons = false;
          background-opacity = 1.0;
          click-action = "minimize";
          custom-theme-shrink = true;
          dash-max-icon-size = lib.gvariant.mkInt32 28;
          dock-fixed = true;
          dock-position = "BOTTOM";
          extend-height = true;
          height-fraction = 0.4;
          icon-size-fixed = false;
          preferred-monitor = lib.gvariant.mkInt32 1;
          preferred-monitor-by-connector = "HDMI-1";
          preview-size-scale = 0.0;
          show-favorites = true;
          show-icons-emblems = false;
          show-mounts = false;
          show-running = true;
          transparency-mode = "FIXED";
        };

        "org/gnome/shell" = {
          enabled-extensions = [
            "blur-my-shell@aunetx"
            "dash-to-dock@micxgx.gmail.com"
          ];
        };
      };
    }
  ];

# ----

# INICIO DO DEBLOAT de DE

environment.gnome.excludePackages = with pkgs; [
  gnome-tour
  orca
  gnome-contacts
  gnome-maps
  gnome-weather
  gnome-characters
  epiphany
  gnome-music
  gnome-photos
];

# fim do debloat de DE
# FIM DA CONFIG DE INTERFACE GRAFICA


  #teclado
  services.xserver.xkb = {
    layout = "br";
    variant = "nodeadkeys";
  };
  console.keyMap = "br-abnt2";

  # desativando impressora
  services.printing.enable = false;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };


  # CONFIG DO USER
  users.users."filipe" = {
    isNormalUser = true;
    description = "filipe";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

#permitir recursos experimentais
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  environment.systemPackages = with pkgs; [
  fastfetch
  firefox
  git
  wget
  kitty # terminal
  nautilus
  dconf
  heroic # GAMES
  ntfs3g #fazer hd funcionar
  corectrl # "MSI afterburner"
  # GNOME / EXTENSIONS
  gnomeExtensions.blur-my-shell
  gnomeExtensions.dash-to-dock
  ];

#small extras

  #facilitar acesso a /etc/nixos/configuration.nix
  programs.bash.shellAliases = {
  config = "sudo nano /etc/nixos/configuration.nix";
  switch = "sudo env PATH=/run/current-system/sw/bin:$PATH nixos-rebuild switch";
  boot = "sudo env PATH=/run/current-system/sw/bin:$PATH nixos-rebuild boot";
  clean = "sudo env PATH=/run/current-system/sw/bin:$PATH nix-collect-garbage -d";  
};

  # fastfetch automatico
  programs.bash = {
  interactiveShellInit = ''
    fastfetch
  '';
 };

 # declaraçao do mount do HD
 fileSystems."/mnt/games" = {
  device = "/dev/disk/by-uuid/F4AC95C1AC957F34";
  fsType = "ntfs";
};

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?
}
