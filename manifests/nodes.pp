class debianlike {
  notify { 'Special manifest for Debian-like systems': }
}

class redhatlike {
  notify { 'Special manifest for RedHat-like Systems': }
}

# using definitions
define tmpfile() {
  file { "/tmp/${name}":
    content => "Hello, world\n",
  }
}

node 'cookbook' {
  #include admin::stages
  #include admin::ntp
  augeas { 'enable-ip-forwarding':
    context => '/files/etc/sysctl.conf',
    changes => ['set net.ipv4.ip_forward 1'],
  }
  include admin::rsyncdconf

  file { '/etc/rsyncd.d/myapp.conf':
    ensure  => present,
    source  => 'puppet:///modules/admin/myapp.rsync',
    require => File['/etc/rsyncd.d'],
    notify  => Exec['update-rsyncd.conf'],
  }

  $mysql_password = 'secret'
  file { '/usr/local/bin/backup-mysql':
    content => template('admin/backup-mysql.sh.erb'),
    mode => '0755',
  }
}
node 'puppet-cookbook' {
  #include admin::stages
  #include admin::ntp
  #include stdlib
  include loopdocker::kubernetes::secure_volumes
}

node test1 {
  append_if_no_such_line { 'enable-ip-conntrack':
    file => '/etc/modules',
    line => 'ip_conntrack',
  }

  replace_matching_line { 'disable-ip-conntrack':
    file    => '/etc/modules',
    match   => '^ip_conntrack',
    replace => '#ip_conntrack',
  }
}
node 'test' {
  # Testing shellquotes
  $source = 'Hello Jerry'
  $target = 'Hello... Newman'
  $argstring = shellquote($source, $target)
  $command = "/bin/mv ${argstring}"
  notify { $command: }
  
  $message = generate('/usr/local/bin/message.rb')
  notify { $message: }
  include admin::stages
  #include admin::ntp
  include admin::ntp_uk

  #file { '/tmp/hello': 
  #  content => "Hello, world\n",
  #}
  #include puppet
  #include memcached

  # using tag
  if tagged('admin::ntp') {
    notify { 'This node is running NTP': }
  }

  if tagged('admin') {
    notify { 'THis node includes at least one class from the admin module': }
  }  

  # Testing if and else statements
  if $::operatingsystem == 'Ubuntu' {
    notify { 'Running on Ubuntu': }
  } else {
    notify { 'Non-Ubuntu system detected. Please upgrade to Ubuntu immediately.': }
  }

  # Testing selector and case statements
  $systemtype = $::operatingsystem ? {
    'Ubuntu'  => 'debianlike',
    'Debian'  => 'debianlike',
    'RedHat'  => 'redhatlike',
    'Fedora'  => 'redhatlike',
    'CentOS'  => 'redhatlike',
    default   => 'unknown',
  }

  notify { "You have a ${systemtype} system": }


  case $::operatingsystem { 
    'Ubuntu',
    'Debian': {
      include debianlike
    }
    'RedHat',
    'Fedora', 
    'CentOS': {
      include redhatlike
    }
    default: {
      notify { " I don't know waht kind of system you have!": }
    }
  }

  # testing case with regular expressions
  case $::lsbdistdescription { 
    /Ubuntu (.+)/: {
      notify { "You have Ubuntu version ${1}": }
    }
    /CentOS (.+)/: {
      notify { "You have CentOS version ${1}": }
    }
    default: {}
  }

  # another selector example
  $lunch = 'Burger' 
  $lunchtype = $lunch ? {
    /fries/ => 'unhealthy',
    /salad/ => 'healthy',
    default => 'unknown',
  }

  notify { "your lunch was ${lunchtype}": }

  # Testing the in operator
  if $::operatingsystem in ['Ubuntu', 'Debian' ] {
    notify { 'Debian-type operating system': }
  } elsif $::operatingsystem in ['RedHat', 'Fedora', 'SuSE', 'CentOS' ]{
    notify { 'RedHat-type operating system detected': }
  } else {
    notify { 'Some other operating system detected': }
  }

  # testing regsubst function
  $class_c = regsubst($::ipaddress, '(.*)\..*', '\1.0')
  notify { "The network part of ${::ipaddress} is ${class_c}": }


  tmpfile { ['a', 'b', 'c']: }
}
