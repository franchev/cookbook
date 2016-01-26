class loopenv::tomcat7service{

  if (! defined(Service['tomcat7'])) {
    service { 'tomcat7':
      enable     => true,
      name       => 'tomcat7',
      ensure     => 'running',
      hasrestart => true,
      hasstatus  => true,
    } ### service

  } ### if

} ### class

