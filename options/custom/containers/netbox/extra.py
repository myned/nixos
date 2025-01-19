# https://github.com/netbox-community/netbox-docker/blob/release/configuration/extra.py

CENSUS_REPORTING_ENABLED = False
LOGIN_PERSISTENCE = True

# BUG: pynetbox does not send token with version requests
# https://github.com/netbox-community/Device-Type-Library-Import/issues/134
# https://github.com/netbox-community/pynetbox/pull/641
# ?? LOGIN_REQUIRED = False
LOGIN_REQUIRED = True

MEDIA_ROOT = "/opt/netbox/netbox/media"  # Default /opt/netbox/media
TIME_ZONE = "America/Chicago"

# https://netboxlabs.com/docs/netbox/en/stable/plugins/installation/
# TODO: Upgrade to v4.2 when supported by plugins
#!! "ImproperlyConfigured: Application labels aren't unique, duplicates: <plugin>" means incompatible version
PLUGINS = [
    "netbox_acls",
    "netbox_attachments",
    "netbox_dns",
    "netbox_interface_synchronization",
    "netbox_inventory",
    # "netbox_lists",
    "netbox_otp_plugin",
    "netbox_reorder_rack",
    # "netbox_routing",
    "netbox_secrets",
    "netbox_storage",
    "netbox_topology_views",
    "nextbox_ui_plugin",
    # "slurpit_netbox",
]

PLUGINS_CONFIG = {
    "netbox_acls": {"top_level_menu": True},
    "netbox_otp_plugin": {"otp_required": False},
    "netbox_secrets": {"top_level_menu": True},
    "netbox_topology_views": {"allow_coordinates_saving": True},
}

shortcuts = """\
|    |    |
|:---|---:|
| [Topology](/plugins/netbox_topology_views/topology/?filter_id=9) ([v2](/plugins/nextbox-ui/topology/?filter_id=3)) | [Racks](/dcim/rack-elevations/) |
| [Networks](/ipam/prefixes/) | [Servers](/dcim/devices/?role_id=3) |
| [VLANs](/ipam/vlans/) | [Clients](/dcim/devices/?role_id=4) |
| [Routers](/dcim/devices/?role_id=1) | [Clusters](/virtualization/clusters/) |
| [Switches](/dcim/devices/?role_id=2) | [VMs](/virtualization/virtual-machines/) |
| [Contacts](/tenancy/contacts/) | [Services](/ipam/services/) |
"""

# https://netboxlabs.com/docs/netbox/en/stable/configuration/default-values/#default_dashboard
DEFAULT_DASHBOARD = [
    {
        "widget": "extras.NoteWidget",
        "width": 4,
        "height": 4,
        "title": "Shortcuts",
        "color": "black",
        "config": {"content": shortcuts},
    },
    {
        "widget": "extras.BookmarksWidget",
        "width": 8,
        "height": 4,
        "title": "Bookmarks",
        "color": "black",
        "config": {"order_by": "name"},
    },
    {
        "widget": "extras.ObjectListWidget",
        "width": 12,
        "height": 5,
        "title": "Journal",
        "color": "black",
        "config": {
            "model": "extras.journalentry",
            "page_size": 5,
        },
    },
    {
        "widget": "extras.ObjectListWidget",
        "width": 12,
        "height": 7,
        "title": "Changelog",
        "color": "black",
        "config": {
            "model": "core.objectchange",
            "page_size": 10,
        },
    },
]
