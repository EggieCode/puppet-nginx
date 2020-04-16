define nginx::http::server (
    Array[String] $listen         = ['80', '[::]:80'],
    Optional[String] $server_name = $name,
    Array[String] $server_aliases = [],
    Boolean $http2                = false,
    Boolean $ssl                  = false,

    String $access_log            = "${nginx::default_log_path}/$name-access.log",
    String $error_log             = "${nginx::default_log_path}/$name-error.log",

    Optional[String] $root        = undef,
    Optional[String] $return      = undef,

    Integer $order                = 10,
) {
    $_order = $order + 10

    concat { "nginx-http-$name":
        ensure         => 'present',
        path           => "${nginx::config_path}/sites-enabled/${_order}-${name}.conf",
        owner          => $nginx::root_user,
        group          => $nginx::root_group,
        mode           => '0644',
        order          => 'numeric',
        warn           => true,
        ensure_newline => true,
        require        => [
            File['nginx.conf'],
        ],
        notify         => [
            Service[$nginx::service_name]
        ]
    }

    concat::fragment { "nginx-http-${name}-header":
        target  => "nginx-http-${name}",
        order   => '1',
        content => epp('nginx/http/server.start.conf.epp', {
            'listen'         => $listen,
            'server_name'    => $server_name,
            'server_aliases' => $server_aliases,
            'http2'          => $http2,
            'ssl'            => $ssl,
            'access_log'     => $access_log,
            'error_log'      => $error_log,

            'root'           => $root,
        }),
    }

    if $return != undef {
        concat::fragment { "nginx-http-${name}-return":
            target  => "nginx-http-${name}",
            order   => 99998,
            content => "return $return;"
        }
    }

    concat::fragment { "nginx-http-${name}-footer":
        target  => "nginx-http-${name}",
        order   => 99999,
        content => "\n}"
    }
}

