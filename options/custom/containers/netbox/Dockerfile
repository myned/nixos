# TODO: Upgrade to v4.1 when supported by netbox-acls
FROM docker.io/netboxcommunity/netbox:v4.0.11

COPY ./plugin_requirements.txt /opt/netbox/
RUN /opt/netbox/venv/bin/pip install --no-warn-script-location -r /opt/netbox/plugin_requirements.txt
