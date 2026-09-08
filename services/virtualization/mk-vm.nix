{
  name,
  desktopName,
  workspace,
  key,
  launcher ? name,
  comment ? "${desktopName} virtual",
  icon ? "computer",
  categories ? [ "System" ],
}:
{
  config,
  lib,
  pkgs,
  me,
  ...
}:

let
  uri = "qemu:///system";
  ws = toString workspace;

  start = pkgs.writeShellApplication {
    name = launcher;
    runtimeInputs = [
      pkgs.libvirt
      pkgs.virt-viewer
      pkgs.procps
      config.programs.hyprland.package
    ];
    text = ''
      if pgrep -f 'virt-viewer.*\b${name}\b' >/dev/null; then
        hyprctl dispatch workspace ${ws} >/dev/null 2>&1 || true
        exit 0
      fi
      case "$(virsh -c ${uri} domstate ${name} 2>/dev/null || true)" in
        running) ;;
        paused) virsh -c ${uri} resume ${name} ;;
        pmsuspended) virsh -c ${uri} dompmwakeup ${name} ;;
        *) virsh -c ${uri} start ${name} ;;
      esac
      exec virt-viewer -c ${uri} --attach --wait --reconnect --auto-resize=always ${name} "$@"
    '';
  };
in
{
  environment.systemPackages = [
    start
    (pkgs.makeDesktopItem {
      inherit
        name
        comment
        icon
        categories
        desktopName
        ;
      exec = lib.getExe start;
    })
  ];

  home-manager.users.${me.name}.wayland.windowManager.hyprland = {
    settings = {
      workspace = [
        "${ws}, defaultName:${desktopName}, gapsin:0, gapsout:0, rounding:false, border:false, shadow:false, on-created-empty:${launcher}"
      ];
      bind = [
        "$mainMod, ${key}, workspace, ${ws}"
        "$mainMod SHIFT, ${key}, movetoworkspace, ${ws}"
      ];
    };

    extraConfig = ''
      windowrule {
        name = vm-${name}
        match:class = ^(org\.virt-manager\.virt-viewer|virt-viewer|remote-viewer)$
        match:title = ^.*\b${name}\b.*$
        workspace = ${ws}
        opacity = 1.0 override 1.0 override
        no_dim = true
        no_blur = true
        no_shadow = true
        rounding = 0
        border_size = 0
      }
    '';
  };
}
