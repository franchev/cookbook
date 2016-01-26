##
## == Class: loopapp::pfrest
## SamsungPay Payment Framework REST Service
##
class loopapp::pfrest (
  $pfrest_package_version = hiera('pfrest_package_version',            'latest'),
  $pfrest_package_name    = hiera('pfrest_package_name',               'loop-pf'),
  $pfrest_ext_url         = hiera('pfrest_ext_url',                    'https://pfrest.prod.looppay.com/pf/v1'),
  $lpcsrv_server          = hiera('lpcsrv_server',                     'aep1-lpc-elb.prod.looppay.com:10001'),
  $lpcsrv_ssl             = hiera('lpcsrv_ssl',                        'false'),
  $apt_loop_key_source    = hiera('apt_loop_key_source_no_password',   'http://repo.dev.looppay.com/keyFile'),
  $apt_loop_release       = hiera('apt_loop_release',                  '/'),
  $apt_loop_key           = hiera('apt_loop_key',                      '428B8369'),
  $looprepos_devphase     = hiera('looprepos_devphase',                'unstable'),
  $apt_loop_repos         = hiera('apt_loop_repos',                    ''),
  ) {

  notify { 'pfrest-info':
    message => "\n\n
      ###########################################
      ###########################################

      SamsungPay Payment Framework REST Service

      * pfrest package version: $pfrest_package_version
      * pfrest package name...: $pfrest_package_name
      * pfrest service ext url: $pfrest_ext_url
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

  apt::source { 'spi_pfrest':
    location    => "http://repo.dev.looppay.com/pfrest-${looprepos_devphase}",
    release     => $apt_loop_release,
    repos       => $apt_loop_repos,
    key         => $apt_loop_key,
    key_source  => $apt_loop_key_source,
    include_src => false
  } ### apt::source looppay

  exec { 'spi-pfrest-apt-get-update':
    path    => $::path,
    command => 'apt-get update',
    require => Apt::Source['spi_pfrest']
  } ### exec

  package { $pfrest_package_name:
    ensure  => $pfrest_package_version,
    #require => [ Package['tomcat7'], Exec['spi-pfrest-apt-get-update'] ],
    require => Exec['spi-pfrest-apt-get-update'],
    notify  => Service['tomcat7'],
  }

  file { '/etc/loop/pf/commons-logging.properties':
    owner   => 'root',
    group   => 'tomcat7',
    mode    => '0640',
    content => 'org.apache.commons.logging.Log=org.apache.commons.logging.impl.Jdk14Logger',
    require => Package[ $pfrest_package_name ],
    notify  => Service['tomcat7'],
  }

  file { '/etc/loop/pf/messages.properties':
    owner   => 'root',
    group   => 'tomcat7',
    mode    => '0640',
    content => '
Email=Email address not valid
NotEmpty=Field cannot be left blank
NotNull=Field cannot be left blank
',
    require => Package[ $pfrest_package_name ],
    notify  => Service['tomcat7'],
  }

  file { '/etc/loop/pf/samsungpfrest.properties':
    owner   => 'root',
    group   => 'tomcat7',
    mode    => '0640',
    content => inline_template('
#######################################
###       Basic configuration       ###
#######################################
# LPC Servers List (comma separated)
servers=<%= @lpcsrv_server %>
#servers=share-integration-001.dev.looppay.com:10001
#servers=localhost:10001

# the external URL that REST clients see
endpointUrl=<%= @pfrest_ext_url %>
#endpointUrl=http://localhost:8080/pf/v1
#endpointUrl=http://share-integration-samsung-looppaytsp.dev.looppay.com:28080/pf/v1

#######################################
###      Advanced Configuration     ###
### Values shown are default values ###
#######################################

#########################
### SSL Configuration ###
#########################

ssl=<%= @lpcsrv_ssl %>
#ssl=false
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
    require => Package[ $pfrest_package_name ],
    notify  => Service['tomcat7'],
  }

} ### class
