##
## == Class: loopapp::resback
## SamsungPay Giftcard resback Service
##
class loopapp::resback (
  $apt_loop_key_source       = hiera('apt_loop_key_source_no_password',   'http://repo.dev.looppay.com/keyFile'),
  $apt_loop_release          = hiera('apt_loop_release',                  '/'),
  $apt_loop_key              = hiera('apt_loop_key',                      '428B8369'),
  $looprepos_devphase        = hiera('looprepos_devphase',                'unstable'),
  $apt_loop_repos            = hiera('apt_loop_repos',                    ''),
  $resback_package_version   = hiera('resback_package_version',           'latest'),
) {

  notify { 'resback-info':
    message => "\n\n
      ###########################################
      ###########################################

      SamsungPay Payment Framework REST Backend

      * resback package version: $resback_package_version

      ###########################################
      ###########################################
    \n\n",
  } ### notify

  apt::source { 'spi_resback':
    location    => "http://repo.dev.looppay.com/resback-${looprepos_devphase}",
    release     => $apt_loop_release,
    repos       => $apt_loop_repos,
    key         => $apt_loop_key,
    key_source  => $apt_loop_key_source,
    include_src => false
  } ### apt::source looppay

  exec { 'spi-resback-apt-get-update':
    path    => $::path,
    command => 'sudo apt-get update',
    require => Apt::Source['spi_resback']
  } ### exec

  package { 'loop-resback':
    ensure  => $resback_package_version,
    require => Exec['spi-resback-apt-get-update']
  }

} ### class
