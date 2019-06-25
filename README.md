# influxsetup.sh [![Build Status](https://travis-ci.org/darrylmosher/influxdata.svg?branch=master)](https://travis-ci.org/darrylmosher/influxdata)

A script to install and configure a complete Influx stack

## Installation

1. Check out a clone of this repo to a location of your choice, such as
   `git clone --depth=1 https://github.com/darrylmosher/influxdata.git ~/.influx`
2. Run `~/.influx/influxsetup.sh

## Usage

```shell
]# ./stacksetup.sh 
Log Location: /tmp/stacksetupout2019-06-25_20:57:07.log

Installing Services

Starting Services

Created Admin user

Updating Configurations

Restarting Services

Complete

Visit http://172.31.105.25:8888 to finish setting up your stack
```

### Admin Credentials

User: admin Password: influxadmin

Update credentials with GraphQL: 
```graphql
SET PASSWORD FOR 'admin' = 'newpass'
```
Additional Information: https://docs.influxdata.com/influxdb/v1.7/administration/authentication_and_authorization/#user-management-commands

### HTTP Authentication

By default, HTTP authentication is disabled.

Enable authentication by setting the auth-enabled option to true in the [http] section of /etc/influxdb/influxdb.conf
```shell
[http]
  # Determines whether HTTP endpoint is enabled.
   enabled = true

  # Determines whether the Flux query endpoint is enabled.
  # flux-enabled = false

  # Determines whether the Flux query logging is enabled.
  # flux-log-enabled = false

  # The bind address used by the HTTP service.
  # bind-address = ":8086"

  # Determines whether user authentication is enabled over HTTP/HTTPS.
    auth-enabled = true
```

If HTTP authentication is enabled, then a username and password must also be defined in the [[influxdb]] section of /etc/kapacitor/kapacitor.conf
```shell
    [[influxdb]]
  # Connect to an InfluxDB cluster
  # Kapacitor can subscribe, query and write to this cluster.
  # Using InfluxDB is not required and can be disabled.
  enabled = true
  default = true
  name = "localhost"
  urls = ["http://localhost:8086"]
  username = "admin"
  password = "influxadmin"
```
Additional Information: https://docs.influxdata.com/influxdb/v1.7/administration/authentication_and_authorization/

## Contributing

1. Fork it (https://github.com/darrylmosher/influxdata/fork)
2. Create your feature branch (git checkout -b a-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin a-new-feature)
5. Create a new Pull Request

## Contributors

- [darrylmosher](https://github.com/darrylmosher) - creator, maintainer