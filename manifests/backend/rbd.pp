# == define: cinder::backend::rbd
#
# Setup Cinder to use the RBD driver.
# Compatible for multiple backends
#
# === Parameters
#
# [*rbd_pool*]
#   (required) Specifies the pool name for the block device driver.
#
# [*rbd_user*]
#   (required) A required parameter to configure OS init scripts and cephx.
#
# [*backend_host*]
#   (optional) Allows specifying the hostname/key used for the owner of volumes
#   created.  This must be set to the same value on all nodes in a multi-node
#   environment.
#   Defaults to 'rbd:<rbd_pool>'
#
# [*volume_backend_name*]
#   (optional) Allows for the volume_backend_name to be separate of $name.
#   Defaults to: $name
#
# [*backend_availability_zone*]
#   (Optional) Availability zone for this volume backend.
#   If not set, the storage_availability_zone option value
#   is used as the default for all backends.
#   Defaults to $::os_service_default.
#
# [*rbd_ceph_conf*]
#   (optional) Path to the ceph configuration file to use
#   Defaults to '/etc/ceph/ceph.conf'
#
# [*rbd_flatten_volume_from_snapshot*]
#   (optional) Enable flatten volumes created from snapshots.
#   Defaults to false
#
# [*rbd_secret_uuid*]
#   (optional) A required parameter to use cephx.
#   Defaults to $::os_service_default
#
# [*rbd_max_clone_depth*]
#   (optional) Maximum number of nested clones that can be taken of a
#   volume before enforcing a flatten prior to next clone.
#   A value of zero disables cloning
#   Defaults to $::os_service_default
#
# [*rados_connect_timeout*]
#   (optional) Timeout value (in seconds) used when connecting to ceph cluster.
#   If value < 0, no timeout is set and default librados value is used.
#   Defaults to $::os_service_default
#
# [*rados_connection_interval*]
#   (optional) Interval value (in seconds) between connection retries to ceph
#   cluster.
#   Defaults to $::os_service_default
#
# [*rados_connection_retries*]
#   (optional) Number of retries if connection to ceph cluster failed.
#   Defaults to $::os_service_default
#
# [*rbd_store_chunk_size*]
#   (optional) Volumes will be chunked into objects of this size (in megabytes).
#   Defaults to $::os_service_default
#
# [*report_dynamic_total_capacity*]
#   (optional) Set to True for driver to report total capacity as a dynamic
#   value
#   Defaults to $::os_service_default
#
# [*rbd_exclusive_cinder_pool*]
#   (optional) Set to True if the pool is used exclusively by Cinder.
#   Defaults to $::os_service_default
#
# [*manage_volume_type*]
#   (Optional) Whether or not manage Cinder Volume type.
#   If set to true, a Cinder Volume type will be created
#   with volume_backend_name=$volume_backend_name key/value.
#   Defaults to false.
#
# [*extra_options*]
#   (optional) Hash of extra options to pass to the backend stanza
#   Defaults to: {}
#   Example :
#     { 'rbd_backend/param1' => { 'value' => value1 } }
#
define cinder::backend::rbd (
  $rbd_pool,
  $rbd_user,
  $backend_host                     = undef,
  $volume_backend_name              = $name,
  $backend_availability_zone        = $::os_service_default,
  $rbd_ceph_conf                    = '/etc/ceph/ceph.conf',
  $rbd_flatten_volume_from_snapshot = $::os_service_default,
  $rbd_secret_uuid                  = $::os_service_default,
  $rbd_max_clone_depth              = $::os_service_default,
  $rados_connect_timeout            = $::os_service_default,
  $rados_connection_interval        = $::os_service_default,
  $rados_connection_retries         = $::os_service_default,
  $rbd_store_chunk_size             = $::os_service_default,
  $report_dynamic_total_capacity    = $::os_service_default,
  $rbd_exclusive_cinder_pool        = $::os_service_default,
  $manage_volume_type               = false,
  $extra_options                    = {},
) {

  include cinder::deps
  include cinder::params

  $rbd_cluster_name = basename($rbd_ceph_conf, '.conf')
  if $rbd_cluster_name == 'ceph' {
    # Do not pass a parameter value in order to avoid service restarts
    $rbd_cluster_name_real = undef
  } else {
    $rbd_cluster_name_real = $rbd_cluster_name
  }

  cinder_config {
    "${name}/volume_backend_name":              value => $volume_backend_name;
    "${name}/backend_availability_zone":        value => $backend_availability_zone;
    "${name}/volume_driver":                    value => 'cinder.volume.drivers.rbd.RBDDriver';
    "${name}/rbd_ceph_conf":                    value => $rbd_ceph_conf;
    "${name}/rbd_user":                         value => $rbd_user;
    "${name}/rbd_pool":                         value => $rbd_pool;
    "${name}/rbd_max_clone_depth":              value => $rbd_max_clone_depth;
    "${name}/rbd_flatten_volume_from_snapshot": value => $rbd_flatten_volume_from_snapshot;
    "${name}/rbd_secret_uuid":                  value => $rbd_secret_uuid;
    "${name}/rados_connect_timeout":            value => $rados_connect_timeout;
    "${name}/rados_connection_interval":        value => $rados_connection_interval;
    "${name}/rados_connection_retries":         value => $rados_connection_retries;
    "${name}/rbd_store_chunk_size":             value => $rbd_store_chunk_size;
    "${name}/rbd_cluster_name":                 value => $rbd_cluster_name_real;
    "${name}/report_dynamic_total_capacity":    value => $report_dynamic_total_capacity;
    "${name}/rbd_exclusive_cinder_pool":        value => $rbd_exclusive_cinder_pool;
    "${name}/report_discard_supported":         value => true;
  }

  if $manage_volume_type {
    cinder_type { $volume_backend_name:
      ensure     => present,
      properties => ["volume_backend_name=${volume_backend_name}"],
    }
  }

  # Avoid colliding with code in backends.pp
  unless defined(Cinder_config["${name}/backend_host"]) {
    if $backend_host {
      cinder_config {
        "${name}/backend_host": value => $backend_host;
      }
    } else {
      cinder_config {
        "${name}/backend_host": value => "rbd:${rbd_pool}";
      }
    }
  }

  ensure_packages( 'ceph-common', {
    ensure => present,
    name   => $::cinder::params::ceph_common_package_name,
    tag    => 'cinder-support-package'})

  create_resources('cinder_config', $extra_options)

  case $::osfamily {
    'Debian': {
      $override_line    = "CEPH_ARGS=\"--id ${rbd_user}\""
      $override_match   = '^CEPH_ARGS='
    }
    'RedHat': {
      $override_line    = "export CEPH_ARGS=\"--id ${rbd_user}\""
      $override_match   = '^export CEPH_ARGS='
    }
    default: {
      fail("unsupported osfamily ${::osfamily}, currently Debian and Redhat are the only supported platforms")
    }
  }

  # Creates an empty file if it doesn't yet exist
  ensure_resource('file', $::cinder::params::ceph_init_override, {'ensure' => 'present'})

  file_line { "set initscript env ${name}":
    line   => $override_line,
    path   => $::cinder::params::ceph_init_override,
    notify => Anchor['cinder::service::begin'],
  }

}
