# Manage FTP
class admin::ntp {
  package { 'ntp':
    ensure  => installed,
  }

  service { 'ntp':
    ensure  => running,
    require => Package['ntp']
  }

  file { '/etc/ntpd.conf':
    source  => 'puppet:///modules/admin/ntp.conf',
    notify  => Service['ntp'],
    require => Package['ntp'],
  }
}
