class loopbasic::aptupdate{

  if (! defined(Exec["apt-get-update"])) {
    exec { "apt-get-update":
      path    => $::path,
      command => "apt-get update",
    } ### exec
  } ### if

} ### class
