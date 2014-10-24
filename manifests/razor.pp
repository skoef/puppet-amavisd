# Documentation goes here
class amavisd::razor (
  $source       = '',
  $template     = '',
  $firewall_dst = [ '0.0.0.0/0', '::/0' ],
) {

  include ::amavisd

  $manage_file_source = $source ? {
    ''      => undef,
    default => $source,
  }

  $manage_file_content = $template ? {
    ''      => undef,
    default => template($template),
  }

  package { 'razor':
    name => 'mail/razor-agents',
  }

  file { 'razor-agent.conf':
    ensure  => file,
    path    => '/usr/local/etc/razor-agent.conf',
    source  => $manage_file_source,
    content => $manage_file_content,
    require => Package['razor'],
  }

  if $amavisd::bool_firewall == true {
    firewall::rule { 'razor-allow-tcp-7':
      direction   => 'output',
      protocol    => 'tcp',
      port        => 7,
      destination => $firewall_dst,
    }

    firewall::rule { 'razor-allow-tcp-2703':
      direction   => 'output',
      protocol    => 'tcp',
      port        => 2703,
      destination => $firewall_dst,
    }
  }
}
