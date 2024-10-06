# https://github.com/netbox-community/netbox-docker/blob/release/configuration/extra.py

CENSUS_REPORTING_ENABLED = False
LOGIN_PERSISTENCE = True

# BUG: pynetbox does not send token with version requests
# https://github.com/netbox-community/Device-Type-Library-Import/issues/134
# https://github.com/netbox-community/pynetbox/pull/641
LOGIN_REQUIRED = True

MEDIA_ROOT = "/opt/netbox/netbox/media"  # Default /opt/netbox/media
TIME_ZONE = "America/Chicago"

PLUGINS = [
    "netbox_acls",
    # // "netbox_attachments",
    "netbox_dns",
    "netbox_interface_synchronization",
    "netbox_lists",
    "netbox_otp_plugin",
    "netbox_reorder_rack",
    # // "netbox_routing",
    "netbox_secrets",
    "netbox_topology_views",
    # // "slurpit_netbox",
]

PLUGINS_CONFIG = {
    "netbox_acls": {"top_level_menu": True},
    "netbox_otp_plugin": {"otp_required": False},
    "netbox_secrets": {"top_level_menu": True},
    "netbox_topology_views": {"allow_coordinates_saving": True},
}
