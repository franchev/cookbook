##
## == Class: loopapp::gcrest
## SamsungPay Giftcard REST Service
##
class loopapp::gcrest (
  $gcrest_package_version = hiera('gcrest_package_version',            'latest'),
  $gcrest_package_name    = hiera('gcrest_package_name',               'loop-gcrest'),
  $gcrest_ext_url         = hiera('gcrest_ext_url',                    'https://gcrest.prod.looppay.com/gift/v1'),
  $lpcsrv_server          = hiera('lpcsrv_server',                     'aep1-lpc-elb.prod.looppay.com:10011'),
  $lpcsrv_ssl             = hiera('lpcsrv_ssl',                        'false'),
  $apt_loop_key_source    = hiera('apt_loop_key_source_no_password',   'http://repo.dev.looppay.com/keyFile'),
  $apt_loop_release       = hiera('apt_loop_release',                  '/'),
  $apt_loop_key           = hiera('apt_loop_key',                      '428B8369'),
  $looprepos_devphase     = hiera('looprepos_devphase',                'unstable'),
  $apt_loop_repos         = hiera('apt_loop_repos',                    ''),
  ) {

  notify { 'gcrest-info':
    message => "\n\n
      ###########################################
      ###########################################

      SamsungPay Payment Framework REST Service

      * gcrest package version: $gcrest_package_version
      * gcrest package name...: $gcrest_package_name
      * gcrest service ext url: $gcrest_ext_url
      * LPC Server............: $lpcsrv_server
      * LPC Uses SSL ?........: $lpcsrv_ssl

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
      #require => Package['tomcat7']
    } ### file
  } ### if

   apt::source { 'spi_gcrest':
    location    => "http://repo.dev.looppay.com/gcrest-${looprepos_devphase}",
    release     => $apt_loop_release,
    repos       => $apt_loop_repos,
    key         => $apt_loop_key,
    key_source  => $apt_loop_key_source,
    include_src => false
  } ### apt::source looppay

  exec { 'spi-gcrest-apt-get-update':
    path    => $::path,
    command => 'apt-get update',
    require => Apt::Source['spi_gcrest']
  } ### exec

  package { $gcrest_package_name:
    ensure  => $gcrest_package_version,
    require => [ Exec['spi-gcrest-apt-get-update'] ],
    notify  => Service['tomcat7'],
  }

  file { '/etc/loop/gift/commons-logging.properties':
    owner   => 'root',
    group   => 'tomcat7',
    mode    => '0640',
    content => 'org.apache.commons.logging.Log=org.apache.commons.logging.impl.Jdk14Logger',
    require => Package[ $gcrest_package_name ],
    notify  => Service['tomcat7'],
  }

  file { '/etc/loop/gift/messages.properties':
    owner   => 'root',
    group   => 'tomcat7',
    mode    => '0640',
    content => '
Email=Email address not valid
NotEmpty=Field cannot be left blank
NotNull=Field cannot be left blank
',
    require => Package[ $gcrest_package_name ],
    notify  => Service['tomcat7'],
  }

  file { '/etc/loop/gift/giftrest.properties':
    owner   => 'root',
    group   => 'tomcat7',
    mode    => '0640',
    content => inline_template('
#######################################
###       Basic configuration       ###
#######################################

# LPC Servers List (comma separated)
servers=<%= @lpcsrv_server %>

# the external URL that REST clients see
endpointUrl=<%= @gcrest_ext_url %>

#######################################
###      Advanced Configuration     ###
### Values shown are default values ###
#######################################

#########################
### SSL Configuration ###
#########################

ssl=<%= @lpcsrv_ssl %>
#trustStoreUrl=[NO DEFAULT]
#trustStorePassword=[NO DEFAULT]

######################################
### Advanced network configuration ###
######################################

#connMinPoolSize=0
#connMaxPoolSize=500
#connIdleTimeout=10
#connectTimeout=3
#readTimeout=30
#tcpNoDelay=true
#retryCount=2
#bufferUnitSize=[NON-SSL:1024,SSL:17408]
#sendBufSize=[NO DEFAULT]
#recvBufSize=[NO DEFAULT]

'),
    require => Package[ $gcrest_package_name ],
    notify  => Service['tomcat7'],
  }

} ### class
