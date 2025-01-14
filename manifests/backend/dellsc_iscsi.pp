# == define: cinder::backend::dellsc_iscsi
#
# Configure the Dell Storage Center ISCSI Driver for cinder.
#
# === Parameters
#
# [*san_ip*]
#   (required) IP address of Enterprise Manager.
#
# [*san_login*]
#   (required) Enterprise Manager user name.
#
# [*san_password*]
#   (required) Enterprise Manager user password.
#
# [*dell_sc_ssn*]
#   (required) The Storage Center serial number to use.
#
# [*target_ip_address*]
#   (optional) The IP address that the iSCSI daemon is listening on.
#   Defaults to undef.
#
# [*volume_backend_name*]
#   (optional) The storage backend name.
#   Defaults to the name of the backend
#
# [*backend_availability_zone*]
#   (Optional) Availability zone for this volume backend.
#   If not set, the storage_availability_zone option value
#   is used as the default for all backends.
#   Defaults to $::os_service_default.
#
# [*dell_sc_api_port*]
#   (optional) The Enterprise Manager API port.
#   Defaults to $::os_service_default
#
# [*dell_sc_server_folder*]
#   (optional) Name of the server folder to use on the Storage Center.
#   Defaults to 'srv'
#
# [*dell_sc_verify_cert*]
#   (optional) Enable HTTPS SC certificate verification
#   Defaults to $::os_service_default
#
# [*dell_sc_volume_folder*]
#   (optional) Name of the volume folder to use on the Storage Center.
#   Defaults to 'vol'
#
# [*target_port*]
#   (optional) The ISCSI IP Port of the Storage Center.
#   Defaults to $::os_service_default
#
# [*excluded_domain_ips*]
#   (optional)Comma separated list of domain IPs to be excluded from
#   iSCSI returns of Storage Center.
#   Defaults to $::os_service_default
#
# [*secondary_san_ip*]
#   (optional) IP address of secondary DSM controller.
#   Defaults to $::os_service_default
#
# [*secondary_san_login*]
#   (optional) Secondary DSM user name.
#   Defaults to $::os_service_default
#
# [*secondary_san_password*]
#   (optional) Secondary DSM user password.
#   Defaults to $::os_service_default
#
# [*secondary_sc_api_port*]
#   (optional) Secondary Dell API port.
#   Defaults to $::os_service_default
#
# [*extra_options*]
#   (optional) Hash of extra options to pass to the backend stanza.
#   Defaults to: {}
#   Example:
#     { 'dellsc_iscsi_backend/param1' => { 'value' => value1 } }
#
# [*manage_volume_type*]
#   (Optional) Whether or not manage Cinder Volume type.
#   If set to true, a Cinder Volume type will be created
#   with volume_backend_name=$volume_backend_name key/value.
#   Defaults to false.
#
# [*use_multipath_for_image_xfer*]
#   (Optional) Enables multipath configuration.
#   Defaults to true.
#
define cinder::backend::dellsc_iscsi (
  $san_ip,
  $san_login,
  $san_password,
  $dell_sc_ssn,
  $target_ip_address            = undef,
  $volume_backend_name          = $name,
  $backend_availability_zone    = $::os_service_default,
  $dell_sc_api_port             = $::os_service_default,
  $dell_sc_server_folder        = 'srv',
  $dell_sc_verify_cert          = $::os_service_default,
  $dell_sc_volume_folder        = 'vol',
  $target_port                  = $::os_service_default,
  $excluded_domain_ips          = $::os_service_default,
  $secondary_san_ip             = $::os_service_default,
  $secondary_san_login          = $::os_service_default,
  $secondary_san_password       = $::os_service_default,
  $secondary_sc_api_port        = $::os_service_default,
  $manage_volume_type           = false,
  $use_multipath_for_image_xfer = true,
  $extra_options                = {},
) {

  include cinder::deps

  warning('The cinder::backend::dellsc_iscsi is deprecated and will be removed in V-release, \
please use cinder::backend::dellemc_sc resource instead.')

  if $dell_sc_server_folder == 'srv' {
    warning("The OpenStack default value of dell_sc_server_folder differs from the puppet module \
default of \"srv\" and will be changed to the upstream OpenStack default in N-release.")
  }

  if $dell_sc_volume_folder == 'vol' {
    warning("The OpenStack default value of dell_sc_volume_folder differs from the puppet module \
default of \"vol\" and will be changed to the upstream OpenStack default in N-release.")
  }

  $driver = 'dell_emc.sc.storagecenter_iscsi.SCISCSIDriver'
  cinder_config {
    "${name}/volume_backend_name":          value => $volume_backend_name;
    "${name}/backend_availability_zone":    value => $backend_availability_zone;
    "${name}/volume_driver":                value => "cinder.volume.drivers.${driver}";
    "${name}/san_ip":                       value => $san_ip;
    "${name}/san_login":                    value => $san_login;
    "${name}/san_password":                 value => $san_password, secret => true;
    "${name}/target_ip_address":            value => $target_ip_address;
    "${name}/dell_sc_ssn":                  value => $dell_sc_ssn;
    "${name}/dell_sc_api_port":             value => $dell_sc_api_port;
    "${name}/dell_sc_server_folder":        value => $dell_sc_server_folder;
    "${name}/dell_sc_verify_cert":          value => $dell_sc_verify_cert;
    "${name}/dell_sc_volume_folder":        value => $dell_sc_volume_folder;
    "${name}/target_port":                  value => $target_port;
    "${name}/excluded_domain_ips":          value => $excluded_domain_ips;
    "${name}/secondary_san_ip":             value => $secondary_san_ip;
    "${name}/secondary_san_login":          value => $secondary_san_login;
    "${name}/secondary_san_password":       value => $secondary_san_password, secret => true;
    "${name}/secondary_sc_api_port":        value => $secondary_sc_api_port;
    "${name}/use_multipath_for_image_xfer": value => $use_multipath_for_image_xfer;
  }

  if $manage_volume_type {
    cinder_type { $volume_backend_name:
      ensure     => present,
      properties => ["volume_backend_name=${volume_backend_name}"],
    }
  }

  create_resources('cinder_config', $extra_options)

}
