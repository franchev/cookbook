class admin::rsyncdconf {
  file { '/etc/rsyncd.d':
    ensure => directory,
  }

  exec { 'update-rsyncd.conf':
    command      => '/bin/cat /etc/rsyncd.d/*.conf > /etc/rsyncd.conf',
    refreshonly => true,
    }
}
