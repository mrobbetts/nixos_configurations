{ pkgs }:
{
      enable = false;
      cudaSupport = false;
      openclSupport = true;
#     extraArgs = [ "--currency monero7" ];
      extraArgs = [ "--currency monero" ];
      configFiles = {
        "config.txt" = ''
          "use_slow_memory" : "warn",
          "nicehash_nonce" : false,
          "aes_override" : null,
          "use_tls" : false,
          "tls_secure_algo" : false,
          "tls_fingerprint" : "",
          "call_timeout" : 10,
          "retry_time" : 10,
          "giveup_limit" : 0,
          "verbose_level" : 4,
          "print_motd" : false,
          "h_print_time" : 5,
          "flush_stdout" : true,
          "daemon_mode" : false,
          "output_file" : "/run/log/xmr-stak.log",
          "httpd_port" : 0,
          "http_login" : "",
          "http_pass" : "",
          "prefer_ipv4" : true,
        '';
        "cpu.txt" = ''
          "cpu_threads_conf" : [
          // Config for only two mem channels populated.
          ${pkgs.lib.concatStringsSep "\n" (map (num: ''    { "low_power_mode" : false, "no_prefetch" : false, "asm" : "auto", "affine_to_cpu" : ${toString num} },'') [ 0 2 4 6 8 10 12 14 18 20 22 24 26 28 30 ])}
          // Config for when we fill up the memory.
          ${pkgs.lib.concatStringsSep "\n" (map (num: ''//  { "low_power_mode" : false, "no_prefetch" : false, "asm" : "auto", "affine_to_cpu" : ${toString num} },'') [ 0 1 2 3 4 5 6 7 16 17 18 19 20 21 22 23])}
          ],
        '';
/*
          "cpu_threads_conf" : [
            { "low_power_mode" : false, "no_prefetch" : true, "affine_to_cpu" : 0 },
            { "low_power_mode" : false, "no_prefetch" : true, "affine_to_cpu" : 1 },
            { "low_power_mode" : false, "no_prefetch" : true, "affine_to_cpu" : 2 },
//            { "low_power_mode" : false, "no_prefetch" : true, "affine_to_cpu" : 3 },
            { "low_power_mode" : false, "no_prefetch" : true, "affine_to_cpu" : 4 },
//            { "low_power_mode" : false, "no_prefetch" : true, "affine_to_cpu" : 5 },
            { "low_power_mode" : false, "no_prefetch" : true, "affine_to_cpu" : 6 },
//            { "low_power_mode" : false, "no_prefetch" : true, "affine_to_cpu" : 7 },
            { "low_power_mode" : false, "no_prefetch" : true, "affine_to_cpu" : 8 },
//            { "low_power_mode" : false, "no_prefetch" : true, "affine_to_cpu" : 9 },
            { "low_power_mode" : false, "no_prefetch" : true, "affine_to_cpu" : 10 },
            { "low_power_mode" : false, "no_prefetch" : true, "affine_to_cpu" : 12 },
            { "low_power_mode" : false, "no_prefetch" : true, "affine_to_cpu" : 14 },
            { "low_power_mode" : false, "no_prefetch" : true, "affine_to_cpu" : 16 },
            { "low_power_mode" : false, "no_prefetch" : true, "affine_to_cpu" : 17 },
            { "low_power_mode" : false, "no_prefetch" : true, "affine_to_cpu" : 18 },
            { "low_power_mode" : false, "no_prefetch" : true, "affine_to_cpu" : 20 },
            { "low_power_mode" : false, "no_prefetch" : true, "affine_to_cpu" : 22 },
            { "low_power_mode" : false, "no_prefetch" : true, "affine_to_cpu" : 24 },
            { "low_power_mode" : false, "no_prefetch" : true, "affine_to_cpu" : 26 },
            { "low_power_mode" : false, "no_prefetch" : true, "affine_to_cpu" : 28 },
            { "low_power_mode" : false, "no_prefetch" : true, "affine_to_cpu" : 30 },
          ],
        '';
*/
        "amd.txt" = ''
          "gpu_threads_conf" : [
            { "index" : 0, "intensity" : 1920, "worksize" : 8, "affine_to_cpu" : false, "strided_index" : 1, "mem_chunk" : 2, "unroll" : 8, "comp_mode" : false },
            { "index" : 0, "intensity" : 1920, "worksize" : 8, "affine_to_cpu" : false, "strided_index" : 1, "mem_chunk" : 2, "unroll" : 8, "comp_mode" : false },
          ],
          "platform_index" : 0,
        '';
        "pools.txt" = ''
          "currency" : "monero",
          "pool_list" : [
            { "pool_address" : "pool.supportxmr.com:5555",
              "wallet_address" : "46wnzSXfMxGER6ZvcTrTh5b6NZwPbKFgbQZZaZ1fADDQHFRh9xWnEz5WiBMFz9GUgMK9ZtvsfRWBLWEsjPBjwT4EU76Ugur",
              "rig_id" : "",
              "pool_password" : "x",
              "use_nicehash" : false,
              "use_tls" : false,
              "tls_fingerprint" : "",
              "pool_weight" : 23
            },
          ],
        '';
      };
}

