# letsencrypt standalone
define letsencrypt::exec::standalone (
  $domains = [$name],
  $server  = $letsencrypt::server,
){
  include letsencrypt
  validate_array($domains)
  validate_string($server)

  $params_domain = join($domains, ' -d ')
  if !letsencrypt_installed($name, $domains) {
    exec{ "letsencrypt-exec-standalone-${name}":
      command  => "letsencrypt certonly -a standalone -d ${params_domain} --renew-by-default --standalone-supported-challenges tls-sni-01 --server ${server}",
      creates  => "/etc/letsencrypt/live/${domains[0]}/fullchain.pem",
      require  => File['/etc/letsencrypt/cli.ini'],
      path     => ['/usr/local/bin', '/usr/bin', '/bin', '/sbin']
    }
  }
}
