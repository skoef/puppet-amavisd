# Documentation goes here
class amavisd (
  $service_name        = $amavisd::params::service_name,
  $package_name        = $amavisd::params::package_name,
  $absent              = $amavisd::params::absent,
  $disable             = $amavisd::params::disable,
  $disableboot         = $amavisd::params::disableboot,
  $service_autorestart = $amavisd::params::service_autorestart,
  $config_dir          = $amavisd::params::config_dir,
  $config_file         = $amavisd::params::config_file,
  $config_file_owner   = $amavisd::params::config_file_owner,
  $config_file_group   = $amavisd::params::config_file_group,
  $config_file_mode    = $amavisd::params::config_file_mode,
  $pidfile             = $amavisd::params::pidfile,
  $source              = $amavisd::params::source,
  $template            = $amavisd::params::template,
  $firewall            = $amavisd::params::firewall,
  $firewall_src        = $amavisd::params::firewall_src,
  $firewall_dst        = $amavisd::params::firewall_dst,
  $firewall_port       = $amavisd::params::firewall_port,
  $options             = {},
) inherits amavisd::params {

  $bool_absent              = any2bool($absent)
  $bool_disable             = any2bool($disable)
  $bool_disableboot         = any2bool($disableboot)
  $bool_service_autorestart = any2bool($service_autorestart)
  $bool_firewall            = any2bool($firewall)

  $manage_package_ensure = $amavisd::bool_absent ? {
    true  => 'absent',
    false => 'installed',
  }

  $manage_service_ensure = $amavisd::bool_disable ? {
    true    => 'stopped',
    default => $amavisd::bool_absent ? {
      true    => 'stopped',
      default => 'running',
    }
  }

  $manage_service_enable = $amavisd::bool_disableboot ? {
    true    => false,
    default => $amavisd::bool_disable ? {
      true    => false,
      default => $amavisd::bool_absent ? {
        true  => false,
        false => true,
      },
    },
  }

  $manage_service_autorestart = $amavisd::bool_service_autorestart ? {
    true  => "Service['amavisd']",
    false => undef,
  }

  $manage_file_ensure = $amavisd::bool_absent ? {
    true  => 'absent',
    false => 'file',
  }

  $manage_file_source = $amavisd::source ? {
    ''      => undef,
    default => $amavisd::source,
  }

  $manage_file_content = $amavisd::template ? {
    ''      => undef,
    default => template($amavisd::template),
  }

  $manage_directory_ensure = $amavisd::bool_absent ? {
    true  => 'absent',
    false => 'directory',
  }

  package { 'amavisd':
    ensure => $manage_package_ensure,
    name   => $amavisd::package_name,
  }

  exec { 'sa-update':
    path    => ['/usr/bin', '/usr/local/bin'],
    command => 'sa-update',
    creates => $amavisd::params::spamassassin_keys_path,
    before  => Service['amavisd'],
  }

  service { 'amavisd':
    ensure  => $manage_service_ensure,
    name    => $amavisd::service_name,
    enable  => $manage_service_enable,
    require => Package['amavisd'],
  }

  file { 'amavisd.conf':
    path    => $amavisd::config_file,
    owner   => $amavisd::config_file_owner,
    group   => $amavisd::config_file_group,
    mode    => $amavisd::config_file_source,
    content => template($amavisd::template),
    notify  => $manage_service_autorestart,
  }

  if $bool_firewall == true {
    firewall::rule { 'amavisd-allow-in':
      protocol    => 'tcp',
      port        => $firewall_port,
      direction   => 'input',
      source      => $firewall_src,
      destination => $firewall_dst,
    }
  }
}
