# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include nginx::service
class nginx::service {

    if $nginx::ensure == 'present' {
        service { $nginx::service_name:
            ensure    => 'running',
            enable    => $nginx::service_enabled,
            subscribe => [
                Package[$nginx::packages::packages]
            ],
            require => [
                Package[$nginx::packages::packages]
            ]
        }
    }

}
