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
  class = "vm-${name}";

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
      pkgs.jq
      pkgs.netcat
      pkgs.freerdp
    ];
    text = ''
      state=$(virsh -c ${uri} domstate ${name} 2>/dev/null || true)
      case "$state" in
        running) ;;
        paused) virsh -c ${uri} resume ${name} ;;
        pmsuspended) virsh -c ${uri} dompmwakeup ${name} ;;
        *) virsh -c ${uri} start ${name} ;;
      esac
      exec 9>"$XDG_RUNTIME_DIR/${class}.lock"
      if ! flock -n 9; then
        hyprctl dispatch 'hl.dsp.focus({ workspace = ${ws} })' >/dev/null 2>&1 || true
        exit 0
      fi
    ''
    + lib.optionalString rdp ''
      case "$state" in
        running | paused) tries=5 ;;
        *) tries=120 ;;
      esac
      for _ in $(seq "$tries"); do
        ip=$(virsh -c ${uri} domifaddr ${name} 2>/dev/null | awk '$3 == "ipv4" { sub("/.*", "", $4); print $4; exit }')
        if [ -n "$ip" ] && nc -z -w 1 "$ip" 3389; then
          size=$(hyprctl -j monitors | jq -r '.[] | select(.focused) | "\((.width / .scale | floor) - .reserved[0] - .reserved[2])x\((.height / .scale | floor) - .reserved[1] - .reserved[3])"')
          SDL_APP_ID=${class} exec sdl-freerdp /v:"$ip" /size:"$size" /cert:ignore +dynamic-resolution +clipboard /sound
        fi
        sleep 1
      done
    ''
    + ''
      exec -a ${class} virt-viewer -c ${uri} --attach --wait --reconnect --auto-resize=always ${name} "$@"
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
      workspace_rule = [
        {
          workspace = ws;
          default_name = desktopName;
          gaps_in = 0;
          gaps_out = 0;
          no_rounding = true;
          no_border = true;
          no_shadow = true;
        }
      ];

      window_rule = [
        {
          name = class;
          match.class = "^${class}$";
          workspace = ws;
          opacity = "1.0 override 1.0 override";
          no_dim = true;
          no_blur = true;
          no_shadow = true;
          rounding = 0;
          border_size = 0;
        }
      ];
    };

    extraConfig = lib.optionalString (key != "") ''
      hl.bind("SUPER + ${key}", hl.dsp.exec_cmd("${lib.getExe start}"))
      hl.bind("SUPER + SHIFT + ${key}", hl.dsp.window.move({ workspace = ${ws} }))
    '';
  };
}
