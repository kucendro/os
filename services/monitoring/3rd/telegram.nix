{ config, me, ... }:

{
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
