define nginx::http::location::uwsgi (
    String $server_name,
    String $location_name                                                          = $name,

    String $target,
    Boolean $uwsgi_buffering                                                       = true,
    String $uwsgi_connect_timeout                                                  = '900s',
    String $uwsgi_read_timeout                                                     = '900s',
    Optional[Hash[String, String]] $uwsgi_set_header                               = undef,

    Optional[Boolean] $uwsgi_ignore_client_abort                                   = undef,
    Optional[Boolean] $uwsgi_intercept_errors                                      = undef,
    Optional[Integer] $uwsgi_limit_rate                                            = undef,
    Optional[Boolean] $uwsgi_request_buffering                                     = undef,
    Optional[String] $uwsgi_send_timeout                                           = undef,
    Optional[Hash[String, String]] $uwsgi_pass_header                              = undef,
    Variant[Enum['default'], Boolean, Hash[String, String], Undef] $uwsgi_redirect = undef,
    Optional[Boolean] $uwsgi_socket_keepalive                                      = undef,

    Optional[String] $uwsgi_ssl_certificate                                        = undef,
    Optional[String] $uwsgi_ssl_certificate_key                                    = undef,
    Optional[String] $uwsgi_ssl_ciphers                                            = undef,
    Optional[String] $uwsgi_ssl_crl                                                = undef,
    Optional[String] $uwsgi_ssl_name                                               = undef,
    Optional[String] $uwsgi_ssl_password_file                                      = undef,
    Optional[Array[
        Enum['TLS1.0', 'TLS1.1', 'TLS1.2', 'TLS1.3']
    ]] $uwsgi_ssl_protocols                                                        = undef,
    Optional[String] $uwsgi_ssl_server_name                                        = undef,
    Optional[Boolean] $uwsgi_ssl_session_reuse                                     = undef,
    Optional[String] $uwsgi_ssl_trusted_certificate                                = undef,
    Optional[Boolean] $uwsgi_ssl_verify                                            = undef,
    Optional[Integer] $uwsgi_ssl_verify_depth                                      = undef,
) {
    $_order = 10 + (getparam(Nginx::Http::Location[$location_name], "order") * 15)

    $config = {
        'uwsgi_read_timeout'            => $uwsgi_read_timeout,
        'uwsgi_request_buffering'       => $uwsgi_request_buffering,
        'uwsgi_buffering'               => $uwsgi_buffering,
        'uwsgi_connect_timeout'         => $uwsgi_connect_timeout,
        'uwsgi_ignore_client_abort'     => $uwsgi_ignore_client_abort,
        'uwsgi_intercept_errors'        => $uwsgi_intercept_errors,
        'uwsgi_limit_rate'              => $uwsgi_limit_rate,
        'uwsgi_redirect'                => $uwsgi_redirect,
        'uwsgi_send_timeout'            => $uwsgi_send_timeout,
        'uwsgi_socket_keepalive'        => $uwsgi_socket_keepalive,
        'uwsgi_ssl_certificate'         => $uwsgi_ssl_certificate,
        'uwsgi_ssl_certificate_key'     => $uwsgi_ssl_certificate_key,
        'uwsgi_ssl_ciphers'             => $uwsgi_ssl_ciphers,
        'uwsgi_ssl_crl'                 => $uwsgi_ssl_crl,
        'uwsgi_ssl_name'                => $uwsgi_ssl_name,
        'uwsgi_ssl_password_file'       => $uwsgi_ssl_password_file,
        'uwsgi_ssl_protocols'           => $uwsgi_ssl_protocols,
        'uwsgi_ssl_server_name'         => $uwsgi_ssl_server_name,
        'uwsgi_ssl_session_reuse'       => $uwsgi_ssl_session_reuse,
        'uwsgi_ssl_trusted_certificate' => $uwsgi_ssl_trusted_certificate,
        'uwsgi_ssl_verify'              => $uwsgi_ssl_verify,
        'uwsgi_ssl_verify_depth'        => $uwsgi_ssl_verify_depth,
        'uwsgi_set_header'              => $uwsgi_set_header,
        'uwsgi_pass_header'             => $uwsgi_pass_header,
        'uwsgi_pass'                    => $target,
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
    ), 'include uwsgi_params;']

    concat::fragment { "nginx-http-${server_name}-${name}-uwsgi":
        target  => "nginx-http-${server_name}",
        order   => $_order + 5,
        content => join($content, "\n"),
    }

}
