{ ... }:
{
  imports = [
    ../global.nix
    ../../services/ai/vllm.nix
    ../../services/connection/ssh.nix
    ../../services/connection/wg.nix
    ../../services/nginx.nix
  ];
}
