# == Class: cinder::key_manager::barbican::service_user
#
# Setup and configure the service token feature for Barbican Key Manager
#
# === Parameters
#
# [*password*]
#  (Required) Password to create for the service user
#
# [*username*]
#  (Optional) The name of the service user
#  Defaults to 'cinder'
#
# [*auth_url*]
#  (Optional) The URL to use for authentication.
#  Defaults to 'http://localhost:5000'
#
# [*project_name*]
#  (Optional) Service project name
#  Defaults to 'services'
#
# [*user_domain_name*]
#  (Optional) Name of domain for $username
#  Defaults to 'Default'
#
# [*project_domain_name*]
#  (Optional) Name of domain for $project_name
#  Defaults to 'Default'
#
# [*system_scope*]
#  (Optional) Scope for system operations.
#  Defaults to $::os_service_default
#
# [*insecure*]
#  (Optional) If true, explicitly allow TLS without checking server cert
#  against any certificate authorities.  WARNING: not recommended.  Use with
#  caution.
#  Defaults to $::os_service_default
#
# [*auth_type*]
#  (Optional) Authentication type to load
#  Defaults to 'password'
#
# [*auth_version*]
#  (Optional) API version of the admin Identity API endpoint.
#  Defaults to $::os_service_default.
#
# [*cafile*]
#  (Optional) A PEM encoded Certificate Authority to use when verifying HTTPs
#  connections.
#  Defaults to $::os_service_default.
#
# [*certfile*]
#  (Optional) Required if identity server requires client certificate
#  Defaults to $::os_service_default.
#
# [*keyfile*]
#  (Optional) Required if identity server requires client certificate
#  Defaults to $::os_service_default.
#
# [*region_name*]
#  (Optional) The region in which the identity server can be found.
#  Defaults to $::os_service_default.
#
class cinder::key_manager::barbican::service_user(
  $password,
  $username            = 'cinder',
  $auth_url            = 'http://localhost:5000',
  $project_name        = 'services',
  $user_domain_name    = 'Default',
  $project_domain_name = 'Default',
  $system_scope        = $::os_service_default,
  $insecure            = $::os_service_default,
  $auth_type           = 'password',
  $auth_version        = $::os_service_default,
  $cafile              = $::os_service_default,
  $certfile            = $::os_service_default,
  $keyfile             = $::os_service_default,
  $region_name         = $::os_service_default,
) {

  include cinder::deps

  oslo::key_manager::barbican::service_user { 'cinder_config':
    username            => $username,
    password            => $password,
    auth_url            => $auth_url,
    project_name        => $project_name,
    user_domain_name    => $user_domain_name,
    project_domain_name => $project_domain_name,
    system_scope        => $system_scope,
    insecure            => $insecure,
    auth_type           => $auth_type,
    auth_version        => $auth_version,
    cafile              => $cafile,
    certfile            => $certfile,
    keyfile             => $keyfile,
    region_name         => $region_name,
  }
}
