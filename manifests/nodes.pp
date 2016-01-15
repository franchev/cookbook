class debianlike {
  notify { 'Special manifest for Debian-like systems': }
}

class redhatlike {
  notify { 'Special manifest for RedHat-like Systems': }
}

node 'cookbook' {
  #file { '/tmp/hello': 
  #  content => "Hello, world\n",
  #}
  #include puppet
  #include memcached


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
}
