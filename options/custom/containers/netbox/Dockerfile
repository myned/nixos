FROM docker.io/netboxcommunity/netbox:v4.1.11

# Install extra configuration
COPY ./extra.py /etc/netbox/config/

# Install plugin modules
COPY ./plugin_requirements.txt /opt/netbox/
RUN /opt/netbox/venv/bin/pip install --no-warn-script-location -r /opt/netbox/plugin_requirements.txt

# Install plugin static files
RUN SECRET_KEY="dummydummydummydummydummydummydummydummydummydummy" /opt/netbox/venv/bin/python /opt/netbox/netbox/manage.py collectstatic --no-input
