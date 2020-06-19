define nginx::http::location::proxy (
    String $server_name,
    String $location_name                                                          = $name,

    String $target,
    Boolean $proxy_buffering                                                       = true,
    String $proxy_connect_timeout                                                  = '900s',
    String $proxy_read_timeout                                                     = '900s',
    Optional[Hash[String, String]] $proxy_set_header                               = undef,

    Enum['1.0', '1.1'] $proxy_http_version                                         = '1.1',
    Optional[Boolean] $proxy_ignore_client_abort                                   = undef,
    Optional[Boolean] $proxy_intercept_errors                                      = undef,
    Optional[Integer] $proxy_limit_rate                                            = undef,
    Optional[Boolean] $proxy_request_buffering                                     = undef,
    Optional[String] $proxy_send_timeout                                           = undef,
    Optional[Hash[String, String]] $proxy_pass_header                              = undef,
    Variant[Enum['default'], Boolean, Hash[String, String], Undef] $proxy_redirect = undef,
    Optional[Boolean] $proxy_socket_keepalive                                      = undef,

    Optional[String] $proxy_ssl_certificate                                        = undef,
    Optional[String] $proxy_ssl_certificate_key                                    = undef,
    Optional[String] $proxy_ssl_ciphers                                            = undef,
    Optional[String] $proxy_ssl_crl                                                = undef,
    Optional[String] $proxy_ssl_name                                               = undef,
    Optional[String] $proxy_ssl_password_file                                      = undef,
    Optional[Array[
        Enum['TLS1.0', 'TLS1.1', 'TLS1.2', 'TLS1.3']
    ]] $proxy_ssl_protocols                                                        = undef,
    Optional[String] $proxy_ssl_server_name                                        = undef,
    Optional[Boolean] $proxy_ssl_session_reuse                                     = undef,
    Optional[String] $proxy_ssl_trusted_certificate                                = undef,
    Optional[Boolean] $proxy_ssl_verify                                            = undef,
    Optional[Integer] $proxy_ssl_verify_depth                                      = undef,
) {
    $_order = 10 + (getparam(Nginx::Http::Location[$location_name], "order") * 15)

    $config = {
        'proxy_read_timeout'            => $proxy_read_timeout,
        'proxy_request_buffering'       => $proxy_request_buffering,
        'proxy_buffering'               => $proxy_buffering,
        'proxy_connect_timeout'         => $proxy_connect_timeout,
        'proxy_http_version'            => $proxy_http_version,
        'proxy_ignore_client_abort'     => $proxy_ignore_client_abort,
        'proxy_intercept_errors'        => $proxy_intercept_errors,
        'proxy_limit_rate'              => $proxy_limit_rate,
        'proxy_redirect'                => $proxy_redirect,
        'proxy_send_timeout'            => $proxy_send_timeout,
        'proxy_socket_keepalive'        => $proxy_socket_keepalive,
        'proxy_ssl_certificate'         => $proxy_ssl_certificate,
        'proxy_ssl_certificate_key'     => $proxy_ssl_certificate_key,
        'proxy_ssl_ciphers'             => $proxy_ssl_ciphers,
        'proxy_ssl_crl'                 => $proxy_ssl_crl,
        'proxy_ssl_name'                => $proxy_ssl_name,
        'proxy_ssl_password_file'       => $proxy_ssl_password_file,
        'proxy_ssl_protocols'           => $proxy_ssl_protocols,
        'proxy_ssl_server_name'         => $proxy_ssl_server_name,
        'proxy_ssl_session_reuse'       => $proxy_ssl_session_reuse,
        'proxy_ssl_trusted_certificate' => $proxy_ssl_trusted_certificate,
        'proxy_ssl_verify'              => $proxy_ssl_verify,
        'proxy_ssl_verify_depth'        => $proxy_ssl_verify_depth,
        'proxy_set_header'              => $proxy_set_header,
        'proxy_pass_header'             => $proxy_pass_header,
        'proxy_pass'                    => $target,
    }.map | $k, $v | {
        $v ? {
            Boolean => $v ? {
                true  => [$k, 'on'],
                false => [$k, 'off']
            },
            default => [$k, $v]
        }
    }
    $config_1 = ($config.filter | $item | { $item[1] =~ Array or $item[1] =~ Hash }).map | $item | {
        $item[1] ? {
            Hash[String, String] => [$item[0], $item[1].map | $k, $v | { "$k $v" }],
            default              => [$item[0], $item[1]]
        }
    }

    $content = [inline_epp(
        "<%- \$config.each |\$item| { \$item[1].each | \$inner_item | { %>        <%= \$item[0] %> <%= \$inner_item %>;\n<%- } } -%>"
        , {
            config => $config_1
        },
    ), inline_epp(
        "<%- \$config.each |\$item| { %>        <%= \$item[0] %> <%= \$item[1] %>;\n<%- } -%>", {
            config => $config.filter | $item | { $item[1] =~ String }
        },
    )]

    concat::fragment { "nginx-http-${server_name}-${name}-proxy":
        target  => "nginx-http-${server_name}",
        order   => $_order + 5,
        content => join($content, "\n"),
    }

}
