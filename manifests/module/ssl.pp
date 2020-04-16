# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include nginx::module::ssl
define nginx::module::ssl (
    Enum['http', 'stream'] $server_type,
    String $server_name                          = $name,
    Stdlib::Absolutepath $certificate_chain,
    Stdlib::Absolutepath $certificate_key,
    String $ssl_ciphers                          = 'ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-SHA384',
    String $ssl_protocols                        = 'TLSv1.2 TLSv1.3',
    Enum['on', 'off'] $ssl_prefer_server_ciphers = 'on',
    Optional[String] $ssl_buffer_size            = undef,
    Optional[String] $ssl_crl                    = undef,
    Optional[String] $ssl_client_certificate     = undef,
    Optional[String] $ssl_ecdh_curve             = undef,
    Optional[String] $ssl_password_file          = undef,
    String $ssl_session_cache                    = 'shared:SSL:50m',
    Optional[String] $ssl_session_ticket_key     = undef,
    Enum['on', 'off'] $ssl_session_tickets       = 'off',
    String $ssl_session_timeout                  = '1d',
    Enum['on', 'off'] $ssl_stapling              = 'on',
    Enum['on', 'off'] $ssl_stapling_verify       = 'on',
    Optional[String] $ssl_stapling_file          = undef,
    Optional[String] $ssl_stapling_responder     = undef,
    Optional[String] $ssl_trusted_certificate    = undef,
    Optional[String] $ssl_verify_client          = undef,
    Optional[String] $ssl_verify_depth           = undef,
    Optional[String] $ssl_handshake_timeout      = undef,
) {

    $config = {
        'ssl_certificate'           => $certificate_chain,
        'ssl_certificate_key'       => $certificate_key,
        'ssl_ciphers'               => $ssl_ciphers,
        'ssl_client_certificate'    => $ssl_client_certificate,
        'ssl_crl'                   => $ssl_crl,
        'ssl_dhparam'               => "${nginx::config_path}/ssl/dhparam.pem",
        'ssl_ecdh_curve'            => $ssl_ecdh_curve,
        'ssl_password_file'         => $ssl_password_file,
        'ssl_prefer_server_ciphers' => $ssl_prefer_server_ciphers,
        'ssl_protocols'             => $ssl_protocols,
        'ssl_session_cache'         => $ssl_session_cache,
        'ssl_session_ticket_key'    => $ssl_session_ticket_key,
        'ssl_session_tickets'       => $ssl_session_tickets,
        'ssl_session_timeout'       => $ssl_session_timeout,
        'ssl_trusted_certificate'   => $ssl_trusted_certificate,
    };

    case $server_type {
        'http': {
            $content = inline_epp(
                "    ssl on;\n<%- \$config.keys.sort.each |\$key| { %>    <%= \$key %> <%= \$config[\$key] %>;\n<%- } -%>\n", {
                    'config'      => delete_undef_values(deep_merge($config, {
                        'ssl_buffer_size'        => $ssl_buffer_size,
                        'ssl_stapling'           => $ssl_stapling,
                        'ssl_stapling_file'      => $ssl_stapling_file,
                        'ssl_stapling_responder' => $ssl_stapling_responder,
                        'ssl_stapling_verify'    => $ssl_stapling_verify,
                    })),
                    'server_type' => $server_type
                }
            )
        }
        'stream': {
            $content = inline_epp(
                "<%- \$config.keys.sort.each |\$key| { %>    <%= \$key %> <%= \$config[\$key] %>;\n<%- } -%>\n", {
                    'config'      => delete_undef_values(deep_merge($config, {
                        'ssl_handshake_timeout' => $ssl_handshake_timeout,
                        'ssl_verify_client'     => $ssl_verify_client,
                        'ssl_verify_depth'      => $ssl_verify_depth,
                    })),
                    'server_type' => $server_type
                }
            )
        }
    }

    concat::fragment { "nginx-${server_type}-${server_name}-ssl":
        target  => "nginx-${server_type}-${server_name}",
        order   => '5',
        content => $content,
    }

}

