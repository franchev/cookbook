import 'nodes.pp'

define append_if_no_such_line($file,$line) {
  exec { "/bin/echo '${line}' >> '${file}'":
    unless => "/bin/grep -Fx '${line}' '${file}'",
  }
}

define replace_matching_line($file,$match,$replace) {
  exec { "/usr/bin/ruby -i -p -e 'sub(%r{$match}, \"$replace\")' ${file}":
    onlyif => "/bin/grep -E '${match}' ${file}",
  }
}
