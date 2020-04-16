define nginx::http::location (
    String $location,
    String $server_name,

    Optional[String] $root                 = undef,
    Optional[String] $root_alias           = undef,
    Optional[String] $default_type         = undef,
    Optional[String] $return               = undef,

    Variant[Array[String], String] $config = [],
    Integer $order                         = 1,
) {
    $_order = 10 + ($order * 15)

    concat::fragment { "nginx-http-${server_name}-${name}-header":
        target  => "nginx-http-${server_name}",
        order   => $_order,
        content => epp("nginx/http/location.conf.epp", {
            "name"         => $location,
            "root"         => $root,
            "alias"        => $root_alias,
            "default_type" => $default_type,
            "config"       => $config ? {
                String        => $config,
                Array[String] => join($config.map | $config_line | { "        $config_line" }, "\n")
            },
        })
    }

    concat::fragment { "nginx-http-${server_name}-${name}-footer":
        target  => "nginx-http-${server_name}",
        order   => $_order + 14,
        content => $return ? {
            String => "        return ${return};\n    }",
            undef => "\n    }",
        }
    }

}