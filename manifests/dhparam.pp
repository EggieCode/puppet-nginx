# == Definition: nginx::dhparam
#
# Creates Diffie Helman parameters.
#
# === Parameters
#  [*path*]    path to write DH parameters to
#  [*ensure*]  ensure whether DH paramers file is present or absent
#  [*size*]    number of bits for the parameter set
#  [*owner*]   file owner. User must exist
#  [*group*]   file group. Group must exist
#  [*mode*]    file mode.
#
# === Requires
#
#   - `puppetlabs/stdlib`
#
define nginx::dhparam (
  Stdlib::Absolutepath      $path     = $name,
  Enum['present', 'absent'] $ensure   = 'present',
  Integer[1]                $size     = 2048,
  String                    $owner    = 'root',
  String                    $group    = 'root',
  String                    $mode     = '0644',
  Boolean                   $fastmode = true,
) {

  dhparam { $path:
    ensure   => $ensure,
    size     => $size,
    fastmode => $fastmode,
  }

  # Set file access
  file { $path:
    ensure  => $ensure,
    owner   => $owner,
    group   => $group,
    mode    => $mode,
    require => Dhparam[$path];
  }
}
