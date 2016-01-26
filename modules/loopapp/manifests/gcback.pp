##
## == Class: loopapp::gcback
## SamsungPay Giftcard gcback Service
##
class loopapp::gcback (
  $apt_loop_key_source     = hiera('apt_loop_key_source_no_password',   'http://repo.dev.looppay.com/keyFile'),
  $apt_loop_release        = hiera('apt_loop_release',                  '/'),
  $apt_loop_key            = hiera('apt_loop_key',                      '428B8369'),
  $looprepos_devphase      = hiera('looprepos_devphase',                'unstable'),
  $apt_loop_repos          = hiera('apt_loop_repos',                    ''),
  $gcback_package_version  = hiera('gcback_package_version',            'latest'),
) {

  notify { 'gcback-info':
    message => "\n\n
      ###########################################
      ###########################################

      SamsungPay Payment Framework GiftCard Backend

      * gcback package version: $gcback_package_version

      ###########################################
      ###########################################
    \n\n",
  } ### notify

  apt::source { 'spi_gcback':
    location    => "http://repo.dev.looppay.com/gcback-${looprepos_devphase}",
    release     => $apt_loop_release,
    repos       => $apt_loop_repos,
    key         => $apt_loop_key,
    key_source  => $apt_loop_key_source,
    include_src => false
  } ### apt::source looppay

  exec { 'spi-gcback-apt-get-update':
    path    => $::path,
    command => 'apt-get update',
    require => Apt::Source['spi_gcback']
  } ### exec

  package { 'loop-gcback':
    ensure  => $gcback_package_version,
    require => Exec['spi-gcback-apt-get-update'],
  }

} ### class
