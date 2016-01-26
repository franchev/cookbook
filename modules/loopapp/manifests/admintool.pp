##
## == Class: loopapp::admintool
##
class loopapp::admintool (
  $suaaback_host                = hiera('suaa_host',                         $::ipaddress_eth0),
  $gcback_host                  = hiera('gcback_host',                       $::ipaddress_eth0),
  $tcofback_host                = hiera('tcofback_host',                     $::ipaddress_eth0),
  $resback_host                 = hiera('resback_host',                      $::ipaddress_eth0),
  $admintool_package_version    = hiera('admintool_package_version',         'latest'),
  $apt_loop_key_source          = hiera('apt_loop_key_source_no_password',   'http://repo.dev.looppay.com/keyFile'),
  $apt_loop_release             = hiera('apt_loop_release',                  '/'),
  $apt_loop_key                 = hiera('apt_loop_key',                      '428B8369'),
  $looprepos_devphase           = hiera('looprepos_devphase',                'unstable'),
  $apt_loop_repos               = hiera('apt_loop_repos',                    ''),
  ) {

  apt::source { 'spi_admintool':
    location    => "http://repo.dev.looppay.com/admintool-${looprepos_devphase}",
    release     => $apt_loop_release,
    repos       => $apt_loop_repos,
    key         => $apt_loop_key,
    key_source  => $apt_loop_key_source,
    include_src => false
  } ### apt::source looppay

  exec { 'spi-admintool-apt-get-update':
    path    => $::path,
    command => 'apt-get update',
    require => Apt::Source['spi_admintool']
  } ### exec

  package { 'loop-admintool':
    ensure  =>$admintool_package_version,
    require =>Exec['spi-admintool-apt-get-update']
  }

  if (! defined(File['/etc/loop'])) {
    file { '/etc/loop':
      ensure => 'directory',
      owner  => 'root',
      group  => 'root',
      mode   => 0755
    } ### file
  } ### if

  file { '/opt/loopctl/etc/loopctl.properties':
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    content => inline_template('
suaa.host=<%= @suaaback_host %>
suaa.port=10091

giftcard.host=<%= @gcback_host %>
giftcard.port=10011

tcof.host=<%= @tcofback_host %>
tcof.port=10021

res.host=<%= @resback_host %>
res.port=10081
    '),
  } ### file

} ### class
