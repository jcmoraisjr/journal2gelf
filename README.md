journal2gelf
============

Export structured log records from the systemd journal and send them to a
Graylog2 server as GELF messages.

Tested on Python 2.7 and Fedora 17 (systemd-44-17) and Fedora 19 (systemd-204).

[![Docker Repository on Quay](https://quay.io/repository/jcmoraisjr/journal2gelf/status "Docker Repository on Quay")](https://quay.io/repository/jcmoraisjr/journal2gelf)

journalctl output format change
-------------------------------

Starting with systemd-190 journalctl switched to an easier to parse single-line
JSON format. This is now the default expected format as of journal2gelf v0.0.3.

For versions of systemd < 190, you must add the `-m` switch.

Run `journalctl --version` to get the systemd version.

Dependencies:
-------------

- graypy

Usage from Docker image
-----------------------

    journalctl -o json -f | docker run -i quay.io/jcmoraisjr/journal2gelf --server <GELF> --port 12201

Install
-------

On Fedora 17+ (or other systems with a version of systemd that includes journal
support):

```
sudo yum install git python-pip
pip-python install git+http://github.com/systemd/journal2gelf.git#egg=journal2gelf
```

Running as a service
--------------------

Create the file `/etc/systemd/system/journal2gelf.service` with the following content.

If running as a Docker container:

    [Unit]
    Description=Journald to GELF (graylog) log relay service
    After=docker.service
    Requires=docker.service
    [Service]
    ExecStartPre=-/usr/bin/docker stop journal2gelf
    ExecStartPre=-/usr/bin/docker rm journal2gelf
    ExecStart=/bin/bash -c 'journalctl -o json -f | docker run \
      --interactive \
      --name journal2gelf \
      quay.io/jcmoraisjr/journal2gelf:latest \
        --server <GELF> \
        --port 12201'
    RestartSec=10s
    Restart=always
    [Install]
    WantedBy=multi-user.target

If installed in the host:

    [Unit]
    Description=Journald to GELF (graylog) log relay service
    [Service]
    ExecStart=/bin/journal2gelf -s localhost -p 12201 -t
    Restart=on-failure
    RestartSec=30
    [Install]
    WantedBy=multi-user.target

Usage:
------

By default, journal2gelf will look for input on stdin. eg:

- Send all logs and exit:

    journalctl -o json | journal2gelf

The `-t` flag can be specified and journal2gelf will automatically
start journalctl in tail mode. This makes it easier to run as a systemd service.

    journal2gelf -t

This is equivalent to running:

    journalctl -o json -f | journal2gelf

Graylog2 server and port can be specified with `-s` and `-p` flags.


License
-------
Copyright 2012 Joe Miller <https://github.com/joemiller>

Released under the MIT license, see LICENSE for details.
