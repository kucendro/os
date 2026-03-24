{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    vllm
  ];

}
