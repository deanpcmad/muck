# Muck

Modifed from [@adamcooke/muck](https://github.com/adamcooke/muck).

Muck is a tool which will backup & store MySQL dump files from remote hosts. Through a simple
configuration file, you can add hosts & databaes which you wish to be backed up and Muck will
connect to those hosts over SSH, grab a dump file using `mysqldump`, encrypt it,
compress it and store it away on its own server and/or upload it to S3.

* Connect to any number of servers and backup any number of databases on each server.
* Encrypt backup files with GPG.
* Tidies up after itself.
* Secure because we connect over SSH before connecting to the database.
* Runs as a service or in a cron.

## Docker

```yml
version: "3"
services:
  muck:
    image: ghcr.io/deanpcmad/muck:latest
    volumes:
      - "./config:/config"
      - "./data:/data"
      - "./ssh:/ssh"
```

## Configuration

```ruby
server do
  # The hostname of the server you wish to backup. Used to connect with SSH and
  # the name of the directory used for storing the backups.
  name "myserver.example.com"

  # The IP address of the server
  ip_address "1.1.1.1"

  # How often you wish to take a backup (in minutes)
  frequency 60

  # Sends a request to this Healthchecks URL every minute
  healthchecks "http://health.deanpcmad.com/ping/abc123"

  ssh do
    # The user that should connect to the server with SSH
    username 'root'
    # The SSH port
    port 22
    # The path to the SSH key that you will authenticate with
    key "/ssh"
  end

  storage do
    # Specifies the directory that backups will be stored for this server. You
    # can use :app_name to insert the name of the app automatically and
    # :database to insert the database name.
    path "/data/:app_name/:database"

    # The number of backups to keep
    keep 50
  end

  encrypt do
    # Should Encryption be enabled?
    enabled false

    # The password used for GPG Encryption
    password "mypassword"
  end

  upload do
    # Should uploads be enabled?
    enabled true

    # The S3 bucket backup files will be uploaded to
    bucket "my-bucket"

    # The directory in which backups will be sorted in the bucket
    # Can set :hostname and :database
    path ":hostname/:database"

    # The number of backups to keep
    keep 50

    # The AWS region in which your bucket is stored
    aws_region "eu-west-2"

    # AWS API keys
    aws_client_id "client-id"
    aws_client_secret "client-secret"
  end

  database do
    # The name of the database
    name "example"
    # The name of the docker container. Will be converted to `app_name-mysql-1`
    app_name "my-app"
    # The username to authenticate to MySQL with
    username "root"
    # The password to authenticate to MySQL with
    password nil
  end

  # The database block above can be repeated within the context of the server
  # to backup multiple databases from the same server.

end
```

## Running Backups

The `muck` command line tool can be used in two ways.

* `muck start` - this will run constantly (and can be backgrounded to turned into a service as appropriate). It will respect the `frequency` option specified for a server and back all servers up whenever they are due for a backup.
* `muck run` - this will take a backup from all servers & database and exit when complete.
* `muck single [server] [database]` - this will run a backup for a given database (name) on a given server (hostname)

## Data

The data directory will populate itself as follows:

* `data/master` - this stores each raw backup as it is downloaded (gzipped)
* `data/manifest.yml` - this stores a list of each master backup with a timestamp and a size

## Changing the defaults

If you wish to change the global defaults, you can create a file in your config directory which includes a `defaults` block. This is the same as the `server` block shown above however the word `server` on the first line should be replaced with `defaults`. Any values you add to the defaults block will be used instead of the system defaults.
