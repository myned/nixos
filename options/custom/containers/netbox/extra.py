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

shortcuts = """
## [Racks](/dcim/rack-elevations/)
## [Topology](/plugins/netbox_topology_views/topology/?filter_id=9)
## [Topology v2](/plugins/nextbox-ui/topology/?filter_id=3)
"""

# https://netboxlabs.com/docs/netbox/en/stable/configuration/default-values/#default_dashboard
DEFAULT_DASHBOARD = [
    {
        "widget": "extras.NoteWidget",
        "width": 3,
        "height": 3,
        "title": "Shortcuts",
        "color": "white",
        "config": {"content": shortcuts},
    },
    {
        "widget": "extras.NoteWidget",
        "width": 9,
        "height": 3,
        "title": "TODO",
        "color": "red",
        "config": {"content": "Nothing to do (yet)."},
    },
    {
        "widget": "extras.ObjectListWidget",
        "width": 12,
        "height": 4,
        "title": "Journal",
        "color": "orange",
        "config": {
            "model": "extras.journalentry",
            "page_size": 5,
        },
    },
    {
        "widget": "extras.ObjectListWidget",
        "width": 12,
        "height": 6,
        "title": "Changelog",
        "color": "black",
        "config": {
            "model": "core.objectchange",
            "page_size": 10,
        },
    },
]
