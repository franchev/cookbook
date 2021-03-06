class loopdocker::kubernetes::secure_volumes ($blackhawk_p12_b64 = hiera('blackhawk_p12_b64', 'bG9vay1pbi1ncGctaGllcmEK'),
                                              $blackhawk_keystore_password = hiera('blackhawk_keystore_password', 'look-in-gpg-hiera'),
                                              $blackhawk_key_password = hiera('blackhawk_key_password', 'look-in-gpg-hiera')
                                             ) {
  
  $blackhawk_keystore_password_b64 = base64('encode', $blackhawk_keystore_password)
  $blackhawk_key_password_b64 = base64('encode', $blackhawk_key_password)

    if (! defined(File['/etc/loop'])) {
      file { '/etc/loop':
        ensure => 'directory',
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
      } ### file
    } ### if

    file { '/etc/loop/k8s_secure_blackhawk.yaml':
      owner => 'root',
      group => 'root',
      mode => '0640',
      content => "
  apiVersion: v1
  kind: Secret
  metadata:
    name: blackhawk
  type: Opaque
  data:
    blackhawk-keystore-password: ${blackhawk_keystore_password_b64}
    blackhawk-key-password: ${blackhawk_key_password_b64}
    blackhawk-keystore: ${blackhawk_p12_b64}
  ",
    require => File['/etc/loop'],
    } ### file

} ### class
