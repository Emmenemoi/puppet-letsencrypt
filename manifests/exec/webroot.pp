# letsencrypt webroot
define letsencrypt::exec::webroot (
  $domains = [$name],
  $webroot = $letsencrypt::webroot,
  $server  = $letsencrypt::server,
  $force_renew = $letsencrypt::force_renew,
){
  include letsencrypt
  validate_array($domains)
  validate_string($server)
  validate_string($webroot)
  validate_bool($force_renew)

  $params_domain = join($domains, ' -d ')

  unless letsencrypt_installed( $domains) {
    if $letsencrypt::firstrun_standalone and $::letsencrypt_firstrun != 'SUCCESS' {
      letsencrypt::exec::standalone{ $name:
        domains => $domains,
        server  => $server,
      }
      ensure_resource('file', ['/etc/facter', '/etc/facter/facts.d'], {'ensure' => 'directory' })
      exec { "letsencrypt-fact-${name}-standalone":
        command => "echo 'letsencrypt_firstrun=SUCCESS' > /etc/facter/facts.d/letsencrypt.txt",
        creates => "/etc/facter/facts.d/letsencrypt.txt",
        path => ["/bin", "/usr/bin", "/usr/sbin"],
        require => Letsencrypt::Exec::Standalone[$name]
      } ->
      exec { "letsencrypt-fact-${name}-standalone-rights":
        command => "chmod 0644 /etc/facter/facts.d/letsencrypt.txt ; chown root:root /etc/facter/facts.d/letsencrypt.txt",
        path => ["/bin", "/usr/bin", "/usr/sbin"]
      }

    } else {
      if $letsencrypt::firstrun_webroot and $::letsencrypt_firstrun != 'SUCCESS' {
        $real_webroot = $letsencrypt::firstrun_webroot
        ensure_resource('file', ['/etc/facter', '/etc/facter/facts.d'], {'ensure' => 'directory' })

        exec { "letsencrypt-fact-${name}-webroot":
          command => "echo 'letsencrypt_firstrun=SUCCESS' > /etc/facter/facts.d/letsencrypt.txt",
          creates => "/etc/facter/facts.d/letsencrypt.txt",
          path => ["/bin", "/usr/bin", "/usr/sbin"],
          require => Exec["letsencrypt-exec-webroot-${name}"]
        } ->
        exec { "letsencrypt-fact-${name}-webroot-rights":
          command => "chmod 0644 /etc/facter/facts.d/letsencrypt.txt ; chown root:root /etc/facter/facts.d/letsencrypt.txt",
          path => ["/bin", "/usr/bin", "/usr/sbin"]
        }

      } else {
        $real_webroot = $webroot
      }

      if $force_renew {
        $renew_option = "--renew-by-default"
      } else {
        $renew_option = "--keep-until-expiring"
      }

      #notify {"/etc/letsencrypt/live/${domains[0]}/fullchain.pem":}
      exec{ "letsencrypt-exec-webroot-${name}":
        command => "letsencrypt certonly -a webroot --webroot-path ${real_webroot} -d ${params_domain} ${renew_option} --expand --server ${server}",
        #creates => "/etc/letsencrypt/live/${domains[0]}/fullchain.pem",
        require  => File['/etc/letsencrypt/cli.ini'],
        path     => ['/usr/local/bin', '/usr/bin', '/bin', '/sbin'],
        notify   => Service["nginx"]
      }
    }
  }
}
