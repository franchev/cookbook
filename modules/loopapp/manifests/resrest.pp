##
## == Class: loopapp::resrest
## SamsungPay Giftcard REST Service
##
class loopapp::resrest (
  $resrest_package_version = hiera('resrest_package_version',          'latest'),
  $resrest_package_name    = hiera('resrest_package_name',             'loop-resrest'),
  $resrest_ext_url         = hiera('resrest_ext_url',                  'https://resrest.prod.looppay.com/res'),
  $lpcsrv_server           = hiera('lpcsrv_server',                    'resback.prod.looppay.com:10081'),
  $lpcsrv_ssl              = hiera('lpcsrv_ssl',                       'true'),
  $apt_loop_key_source    = hiera('apt_loop_key_source_no_password',   'http://repo.dev.looppay.com/keyFile'),
  $apt_loop_release       = hiera('apt_loop_release',                  '/'),
  $apt_loop_key           = hiera('apt_loop_key',                      '428B8369'),
  $looprepos_devphase     = hiera('looprepos_devphase',                'unstable'),
  $apt_loop_repos         = hiera('apt_loop_repos',                    ''),
  ) {

  notify { 'resrest-info':
    message => "\n\n
      ###########################################
      ###########################################

      Resource (res) REST Service

      * resrest package version: $resrest_package_version
      * resrest package name...: $resrest_package_name
      * resrest service ext url: $resrest_ext_url
      * LPC Server.............: $lpcsrv_server
      * LPC Uses SSL ?.........: $lpcsrv_ssl

      ###########################################
      ###########################################
    \n\n",
  } ### notify

  if (! defined(Class['loopbasic::aptupdate'])) {
    class { 'loopbasic::aptupdate': }
  } ### if

  if (! defined(Class['loopenv::tomcat7service'])) {
    class { 'loopenv::tomcat7service': }
  } ### if

  if (! defined('/var/lib/tomcat7/webapps/ROOT/index.html')) {
    file { '/var/lib/tomcat7/webapps/ROOT/index.html':
      owner   => 'root',
      group   => 'tomcat7',
      mode    => '0640',
      content => '<html>
        <head>
        <meta http-equiv="refresh" content="0;URL=http://www.looppay.com/">
        </head>
        <body>
        </body>
        </html>',
      require => Package['tomcat7']
    } ### file
  } ### if

  apt::source { 'spi_resrest':
    location    => "http://repo.dev.looppay.com/resrest-${looprepos_devphase}",
    release     => $apt_loop_release,
    repos       => $apt_loop_repos,
    key         => $apt_loop_key,
    key_source  => $apt_loop_key_source,
    include_src => false
  } ### apt::source looppay

  exec { 'spi-resrest-apt-get-update':
    path    => $::path,
    command => 'apt-get update',
    require => Apt::Source['spi_resrest']
  } ### exec

  package { $resrest_package_name:
    ensure  => $resrest_package_version,
    require => [ Package['tomcat7'], Exec['spi-resrest-apt-get-update'] ],
    notify  => Service['tomcat7'],
  }

  file { '/etc/loop/gift/commons-logging.properties':
    owner   => 'root',
    group   => 'tomcat7',
    mode    => '0640',
    content => 'org.apache.commons.logging.Log=org.apache.commons.logging.impl.Jdk14Logger',
    require => Package[ $resrest_package_name ],
    notify  => Service['tomcat7'],
  }

  file { '/etc/loop/res/messages.properties':
    owner   => 'root',
    group   => 'tomcat7',
    mode    => '0640',
    content => '
Email=Email address not valid
NotEmpty=Field cannot be left blank
NotNull=Field cannot be left blank
',
    require => Package[ $resrest_package_name ],
    notify  => Service['tomcat7'],
  }

  file { '/etc/loop/res/giftrest.properties':
    owner   => 'root',
    group   => 'tomcat7',
    mode    => '0640',
    content => inline_template('
servers=<%= @lpcsrv_server %>
endpointUrl=<%= @resrest_ext_url %>
enforceAppToken=true
ssl=<%= @lpcsrv_ssl %>
'),
    require => Package[ $resrest_package_name ],
    notify  => Service['tomcat7'],
  }

} ### class
