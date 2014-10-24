# Documentation goes here
class amavisd::spamassassin (
  $source       = '',
  $template     = '',
  $firewall_dst = [
    'spamassassin.apache.org',
    'updates.spamassasin.org',
    'sa-update.space-pro.be',
    'sa-update.secnap.net',
    'www.sa-update.pccc.com',
    'sa-update.dnswl.org'
  ],
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

  file { 'spamassassin.conf':
    ensure  => file,
    path    => '/usr/local/etc/mail/spamassassin/local.cf',
    source  => $manage_file_source,
    content => $manage_file_content,
    notify  => $amavisd::manage_service_autorestart,
  }

  if $amavisd::bool_firewall == true {
    firewall::rule { 'spamassassin-update':
      direction   => 'output',
      destination => $firewall_dst,
      protocol    => 'tcp',
      port        => 80
    }
  }

  cron { 'spamassassin-sa-update':
    command => "(/usr/local/bin/sa-update; /usr/local/etc/rc.d/amavisd restart 2>/dev/null; sleep 120; pgrep -f amavisd 2>/dev/null || /usr/local/etc/rc.d/amavisd start)",
    hour    => fqdn_rand(5, $name),
    minute  => fqdn_rand(59, $name),
  }

}
