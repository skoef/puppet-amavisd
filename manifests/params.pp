#
class amavisd::params {
  $config_file = $::operatingsystem ? {
    /(?i:FreeBSD)/ => '/usr/local/etc/amavisd.conf',
  }

  $config_file_owner   = $::operatingsystem ? {
    default => 'root',
  }

  $config_file_group   = $::operatingsystem ? {
    /(?i:FreeBSD)/ => 'wheel',
    default        => 'root',
  }

  $pidfile = $::operatingsystem ? {
    /(?i:FreeBSD)/ => '/var/amavis/amavisd.pid',
  }

  $package_name = $::operatingsystem ? {
    /(?i:FreeBSD)/ => 'security/amavisd-new',
  }

  $service_name = $::operatingsystem ? {
    /(?i:FreeBSD)/ => 'amavisd',
  }

  $spamassassin_keys_path = $::operatingsystem ? {
    /(?i:FreeBSD)/ => '/usr/local/etc/mail/spamassassin/sa-update-keys',
  }

  $absent              = false
  $disable             = false
  $disableboot         = false
  $service_autorestart = true
  $config_file_mode    = '0644'
  $source              = ''
  $template            = ''
  $firewall            = false
  $firewall_src        = ['0.0.0.0', '::/0']
  $firewall_dst        = ['0.0.0.0', '::/0']
  $firewall_port       = 10024
  $manage_spamassassin = true
  $manage_razor        = true
  $options             = {}
}
