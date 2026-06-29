{
  ssh = {
    user = "u0_a401";
    port = 8022;
  };

  reaches = [
    "nixbook"
    "nas"
    "edge"
    "mac"
  ];

  trustedBy = [
    "nixbook-pubkey"
    "mac-pubkey"
  ];
}
