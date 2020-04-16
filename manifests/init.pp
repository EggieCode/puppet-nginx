# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include nginx
class nginx (
    Enum['present', 'absent'] $ensure,

    String $user,
    String $group,

    Integer $uid,
    Integer $gid,
    String $user_home,
    String $user_shell,

    String $root_user,
    String $root_group,

    String $config_path,
    String $nginx_conf,
    String $pid_file,

    String $service_name,
    Boolean $service_enabled    = true,

    String $default_log_path,
    String $default_log_access,
    String $default_log_error,

    Integer $worker_processes   = $::facts['virtual'] ? {
        'lxc'   => $::facts['processors']['models'] ? {
            undef   => $::facts['processors']['count'],
            default => count($::facts['processors']['models'])
        },
        default => $::facts['processors']['count'],
    },
    Integer $worker_connections = 2048,

    Boolean $http_service       = true,

    #   String $errorpagetemplate
) {

    class { 'nginx::packages':
    } ->

    group { $group:
        ensure => 'present',
        gid    => $gid,
    } ->

    user { $user:
        ensure     => 'present',
        gid        => $gid,
        uid        => $uid,
        managehome => true,
        home       => $user_home,
        shell      => $user_shell,
    } ->

    file { $config_path:
        ensure  => $ensure ? {
            'present' => 'directory',
            default   => 'absent',
        },
        path    => $config_path,
        owner   => $root_user,
        group   => $root_group,
        mode    => '0755',
        purge   => true,
        recurse => true,
        force   => true,
    }

    file { 'nginx.conf':
        ensure  => $ensure ? {
            'present' => 'file',
            default   => 'absent',
        },
        path    => $nginx_conf,
        owner   => $root_user,
        group   => $root_group,
        mode    => '0644',
        content => epp('nginx/nginx.conf.epp'),
        notify  => [
            Service[$nginx::service_name]
        ],
        require => File[$config_path],
    }

    file { 'nginx-mime.types':
        ensure  => $ensure ? {
            'present' => 'file',
            default   => 'absent',
        },
        path    => "$config_path/mime.types",
        notify  => [
            Service[$nginx::service_name]
        ],
        require => File[$config_path],
    }

    file { "$config_path/http.conf.d":
        ensure  => $ensure ? {
            'present' => 'directory',
            default   => 'absent',
        },
        owner   => $root_user,
        group   => $root_group,
        mode    => '0755',
        purge   => true,
        recurse => true,
        force   => true,
        require => File[$config_path],
    }

    file { "$config_path/sites-enabled":
        ensure  => $ensure ? {
            'present' => 'directory',
            default   => 'absent',
        },
        owner   => $root_user,
        group   => $root_group,
        mode    => '0755',
        purge   => true,
        recurse => true,
        force   => true,
        require => File[$config_path],
    }

    file { "$config_path/ssl":
        ensure  => $ensure ? {
            'present' => 'directory',
            default   => 'absent',
        },
        owner   => $root_user,
        group   => $root_group,
        mode    => '0750',
        purge   => false,
        require => File[$config_path],
    }

    file { $default_log_path:
        ensure => 'directory',
        owner  => $user,
        group  => $group,
        mode   => '755',
    }

    nginx::dhparam { "$config_path/ssl/dhparam.pem":
        owner    => 'root',
        group    => $nginx::group,
        mode     => '0740',
        fastmode => true,
    }

    class { 'nginx::service':
        require => [
            File['nginx.conf'],
        ]
    }

}
