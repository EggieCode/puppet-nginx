# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include nginx::packages
class nginx::packages {
    if $nginx::ensure == 'present' {
        $packages = lookup('nginx::packages', Array[String], 'deep')
            + lookup('nginx::packages_deps', Array[String], 'deep')
    } else {
        $packages = lookup('nginx::packages', Array[String], 'deep')
    }

    ensure_packages(
        $packages,
        {
            'ensure' =>
            $nginx::ensure ? {
                'present' => 'latest',
                default   => 'absent'
            }
        }
    )

}
