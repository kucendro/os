{
  config,
  lib,
  pkgs,
  me,
  ...
}:

let
  telegram-notify = pkgs.writeShellApplication {
    name = "telegram-notify";
    runtimeInputs = [ pkgs.curl ];
    text = ''
      unit="$1"
      text="${config.networking.hostName}: $unit failed
      $(journalctl -u "$unit" -n 12 --no-pager -o cat)"
      curl -sf -X POST "https://api.telegram.org/bot$(cat ${config.sops.secrets.grafana-telegram-bottoken.path})/sendMessage" \
        --data-urlencode "chat_id=${toString me.telegram.chatId}" \
        --data-urlencode "text=$text" > /dev/null
    '';
  };
in
{
  systemd.services."telegram-notify@" = {
    description = "Telegram message about failed unit %i";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${lib.getExe telegram-notify} %i";
    };
  };

  services.grafana.provision.alerting.contactPoints.settings = {
    apiVersion = 1;
    contactPoints = [
      {
        orgId = 1;
        name = "Telegram bot";
        receivers = [
          {
            uid = "afr3gp4x53myoc";
            type = "telegram";
            settings = {
              bottoken = "$__file{${config.sops.secrets.grafana-telegram-bottoken.path}}";
              chatid = me.telegram.chatId;
              disable_notification = false;
              disable_web_page_preview = false;
              message = ''{{ template "telegram.default.message" . }}'';
              protect_content = false;
            };
            disableResolveMessage = true;
          }
        ];
      }
    ];
  };
}
