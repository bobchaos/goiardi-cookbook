# cinc-goiardi cookbook

This cookbook provides resources to install [goiardi](http://goiardi.gl/),
[schob](https://github.com/ctdk/schob/) and a complementary
[serf](https://www.serf.io/) resource (which may in time find it's way to a
seperate serf cookbook).

## Requirements

Tested on:

- Cinc Client version 15
- Centos 7
- Debian 8
- Debian 9
- Ubuntu 18.04
- Ubuntu 16.04
- Amazon Linux 2

Being assembled using only platform agnostic methods, it _should_ work on other
unix-like systems, but mileage may vary.

## Resources

### goiardi\_install

Installs a precompiled binary from github.com, or a custom url. Full syntax
with default values:

```
goiardi_install 'goiardi' do
  instance_name resource_name # Defaults to the resource name, used to generate paths and sub-resources
  instance_path '/usr/sbin'   # Where to put the binary. /usr/sbin is FHS compliant, but /usr/local/sbin could be argued as better.
  version 'latest'            # must be either 'latest' or a git tag. Ignored if bin_url is set explicitely
  bin_url nil                 # Left nil, the url will be autoresolved based on `version`
  user resource_name          # File and service owner
  group resource_name         # File group
  private_key_path nil        # Path to the signing private key. Left `nil`, one will be generated automatically if `use-shovey` is set in the goiardi configuration
  manage_systemd_service true # Set to false if you're not on systemd or prefer to write your own unit
  manage_conf true            # Set to false if you're supplying your own configuration file. You'll need to set `options` accordingly
  conf {}                     # Configuration entries to merge/override the defaults. Use `nil` to negate a default entirely
  options nil                 # CLI flags used in the service definition. Left nil, will default to `-c /path/to/conf`
  serf_unit_name 'serf'       # Will be added as `name.service` to the systemd unit's "After" and "Requires". Ignored if `manage_systemd_service` is `false`
  action :create              # Supports :create, :remove
end
```

Leaving `version` at it's default of 'latest' will result in goiardi
auto-updating with each client run. You probably don't want that happening in
prod o.O

`conf` is a hash of [Goiardi configuration
directives](https://goiardi.readthedocs.io/en/latest/installation.html#configuration)
that is merged in with some sane defaults, intended to create a standalone and
persistent Goiardi installation. Default directives can be overriden with
either a new value or `nil` to have them ommited entirely.

`options` is a string of [Goiardi CLI
options](https://goiardi.readthedocs.io/en/latest/installation.html#configuration)
to add to the `systemd_unit`'s `ExecStart`. Left `nil`, it will read from the
generated configuration file. If `generate_conf_file` is `false`, you can pass
your own configuration file and/or run-time options here.

### goiardi\_schob

Installs a precompiled binary of Schob, the Goiardi Shovey job client. Full
syntax with default values:

```
goiardi_schob 'schob' do
  instance_name resource_name # Defaults to the resource name, used to generate paths and sub-resources
  instance_path '/usr/sbin'   # Where to put the binary. /usr/sbin is FHS compliant, but /usr/local/sbin could be argued as better.
  version 'latest'            # must be either 'latest' or a git tag. Ignored if bin_url is set explicitely
  bin_url nil                 # Left nil, the url will be autoresolved based on `version`
  user resource_name          # Asset owner, defaults to the resource's name
  group resource_name         # Asset group, defaults to resource's name
  conf {}                     # Configuration entries to merge/override the defaults. USe `nil` to negate a default entirely
  whitelist { whitelist: { 'chef-client': 'chef-client', 'cinc-client': 'cinc-client' } } # See below
  server_public_key nil       # Required property, the contents of the Shovey server public key.
  manage_conf true            # Set to `false` if you prefer to manage the configuration file through other means
  manage_systemd_service true # Set to false if you're not n systemd or want to handle it through other means
  options nil                 # A string of CLI options for Schob. Defaults to reading everything from the configuration file
  serf_unit_name 'serf'       # Will be added as `name.service` to the systemd unit's "After" and "Requires". Ignored if `manage_systemd_service` is `false`
end
```

Leaving `version` at it's default of 'latest' will result in Schob
auto-updating with each client run. You probably don't want that happening in
prod o.O

`conf` is a hash of [Schob configuration
directives](https://github.com/ctdk/schob) that is merged in with some sane
defaults, intended to create a simple but sturdy installation. Default
directives can be overriden with either a new value or `nil` to have them
ommited entirely.

`whitelist` is a hash of valid commands that shovey can execute. There is no
detailed documentation avaialble at this time but the author provides [this
example](https://github.com/ctdk/schob/blob/master/test/whitelist.json) for
reference.

`options` is a string of [Schob CLI options](https://github.com/ctdk/schob) to
add to the `systemd_unit`'s `ExecStart`. Left `nil`, it will read from the
generated configuration file. If `generate_conf_file` is `false`, you can pass
your own configuration file and/or run-time options here.

### goiardi\_serf

This one is out-of-scope, but provided for convenience. It installs Hashicorp
Serf, which is required by Shovey jobs. Full syntax:

```
goiardi_serf 'serf' do
  instance_name resource_name  # Defaults to the resource name
  instance_path '/usr/sbin'    # Where to put the binary. /usr/sbin is FHS compliant, but /usr/local/sbin could be argued as better.
  version '0.8.2'              # Ignored if bin_url is set explicitely
  archive_url nil              # Left nil, the url will be autoresolved based on `version`
  archive_dir nil              # Where to put the zip file. If left nil, will go to the serf user's home
  user resource_name           # Asset owner, defaults to the resource's name
  group resource_name          # Asset group, defaults to resource's name
  manage_systemd_service false # Set to false if you're not on systemd or want to handle it through other means
  conf {}                      # Configuration entries to merge/override the defaults. USe `nil` to negate a default entirely
  options nil                  # A string of CLI options for Serf. Defaults to reading everything from the configuration
 file
end
```

`conf` is a hash of [Serf configuration
directives](https://www.serf.io/docs/agent/options.html) that is merged in with
some sane defaults, intended to create an installation tailored to Goiardi
Shovey jobs. Default directives can be overriden with either a new value or
`nil` to have them ommited entirely.

`options` is a string of [Serf CLI
options](https://www.serf.io/docs/agent/options.html) to add to the
`systemd_unit`'s `ExecStart`. Left `nil`, it will read from the generated
configuration file.

### Important notes on key handling

Giardi Shovey jobs require that you generate a cryptographic keypair. The
`goiardi_install` and `goiardi_schob` resources will both generate a keypair by
default but it is highly recommend to generate your own key out-of-band and
deploy it using secure mechanisms.

To use your own key with `goiardi_install`, put your key somewhere restricted
on disk and point to it with the `private_key_path` property. `goiardi_install`
will chown/chmod the key as needed.

Its best to have all references to your private key go through a secret manager
such as Hashicorp Vault, which is [natively supported by
Goiardi](https://goiardi.readthedocs.io/en/latest/features/secrets.html). The
resources supports configuring Vault through the `conf` properties.

Finally, the `goiardi_schob` resource requires the `goiardi_install` public key
to function. Being a public key, you can put it cleartext in your private
cookbook without much worry, or read it from a file on drive with ruby's
`IO.read` (or similar methods). Remember to use `lazy {}` to read the key if it
is created in the same run.

## Recipe examples

A minimal install, best used only for testing:

```
goiardi_install 'goiardi'
```

A more complete example, with explicit version, configuration overrides,
Postgres as a database backend and shovey enabled:

```
ze_conf = {
    # 'time-slew' is included by default, but we don't want it in our conf
    'time-slew': nil,
    # Override the default log level of 'warning' with 'fatal'
    'log-level': 'fatal',
    # Activate and configure postgresql support
    'use-postgresql': true,
    'postgresql-username': 'pguser',
    'postgresql-password': 'PleaseGetMeFromVault!',
    'postgresql-host': 'localhost',
    'postgresql-port': 5432,
    'postgresql-dbname': 'goiardi',
    'postgresql-ssl=mode': 'enable'
    # Activate Shovey. `sign-priv-key` should be automatically resolved so we omit it
    'use-serf': true,
    'use-shovey': true,
  }

goiardi_install 'goiardi' do
  version 'v.0.11.10'
  user 'my_custom_system_user'
  group 'my_custom_system_group'
  conf ze_conf # This could very well be a free-form attribute
end
```

Minimalist client node example:

```
remote_file '/etc/shovey.pub' do
  source 'http://webserver.myorg.tld/shovey_server.pub'
  mode '0644'
  action :create
end

goiardi_serf 'serf'

goiardi_schob 'schob' do
  goiardi_endpoint '127.0.0.1:4545'
  server_public_key { IO.read('/etc/shovey.pub') }
end
```

## Contributing

See CONTRIBUTING.md

## License

[Apache-2.0](https://opensource.org/licenses/Apache-2.0)

## Authors

The Cinc project

cookbooks@cinc.sh
