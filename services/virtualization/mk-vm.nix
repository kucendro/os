{
  name,
  desktopName,
  workspace,
  key,
  launcher ? name,
  comment ? "${desktopName} virtual",
  icon ? "computer",
  categories ? [ "System" ],
  rdp ? false,
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
  rdpClass = "vm-${name}";

  start = pkgs.writeShellApplication {
    name = launcher;
    runtimeInputs = [
      pkgs.libvirt
      pkgs.virt-viewer
      pkgs.util-linux
      config.programs.hyprland.package
    ]
    ++ lib.optionals rdp [
      pkgs.coreutils
      pkgs.gawk
      pkgs.netcat
      pkgs.freerdp
    ];
    text = ''
      exec 9>"$XDG_RUNTIME_DIR/vm-${name}.lock"
      if ! flock -n 9; then
        hyprctl dispatch workspace ${ws} >/dev/null 2>&1 || true
        exit 0
      fi
      state=$(virsh -c ${uri} domstate ${name} 2>/dev/null || true)
      case "$state" in
        running) ;;
        paused) virsh -c ${uri} resume ${name} ;;
        pmsuspended) virsh -c ${uri} dompmwakeup ${name} ;;
        *) virsh -c ${uri} start ${name} ;;
      esac
    ''
    + lib.optionalString rdp ''
      case "$state" in
        running | paused) tries=5 ;;
        *) tries=120 ;;
      esac
      for _ in $(seq "$tries"); do
        ip=$(virsh -c ${uri} domifaddr ${name} 2>/dev/null | awk '$3 == "ipv4" { sub("/.*", "", $4); print $4; exit }')
        if [ -n "$ip" ] && nc -z -w 1 "$ip" 3389; then
          SDL_APP_ID=${rdpClass} exec sdl-freerdp /v:"$ip" /cert:ignore +dynamic-resolution +clipboard /sound
        fi
        sleep 1
      done
    ''
    + ''
      exec virt-viewer -c ${uri} --attach --wait --reconnect --auto-resize=always ${name} "$@"
    '';
  };

  rule = id: matches: ''
    windowrule {
      name = ${id}
    ${lib.concatMapStrings (m: "  ${m}\n") matches}  workspace = ${ws}
      opacity = 1.0 override 1.0 override
      no_dim = true
      no_blur = true
      no_shadow = true
      rounding = 0
      border_size = 0
    }
  '';
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
        "${ws}, defaultName:${desktopName}, gapsin:0, gapsout:0, rounding:false, border:false, shadow:false"
      ];
      bind = lib.optionals (key != "") [
        "$mainMod, ${key}, exec, ${lib.getExe start}"
        "$mainMod SHIFT, ${key}, movetoworkspace, ${ws}"
      ];
    };

    extraConfig =
      rule "vm-${name}" [
        "match:class = ^(org\\.virt-manager\\.virt-viewer|virt-viewer|remote-viewer)$"
        "match:title = ^.*\\b${name}\\b.*$"
      ]
      + lib.optionalString rdp (rule "vm-${name}-rdp" [ "match:class = ^${rdpClass}$" ]);
  };
}
