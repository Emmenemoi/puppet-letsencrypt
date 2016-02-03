# letsencrypt standalone
define letsencrypt::exec::standalone (
  $domains = [$name],
  $server  = $letsencrypt::server,
  $force_renew = $letsencrypt::force_renew,
){
  include letsencrypt
  validate_array($domains)
  validate_string($server)
  validate_bool($force_renew)

  $params_domain = join($domains, ' -d ')
  unless letsencrypt_installed($domains) {
    if $force_renew {
      $renew_option = "--renew-by-default"
    } else {
      $renew_option = "--keep-until-expiring"
    }

    exec{ "letsencrypt-exec-standalone-${name}":
      command  => "letsencrypt certonly -a standalone -d ${params_domain} ${renew_option} --expand --standalone-supported-challenges tls-sni-01 --server ${server}",
      creates  => "/etc/letsencrypt/live/${domains[0]}/fullchain.pem",
      require  => File['/etc/letsencrypt/cli.ini'],
      path     => ['/usr/local/bin', '/usr/bin', '/bin', '/sbin']
    }
  }
}
