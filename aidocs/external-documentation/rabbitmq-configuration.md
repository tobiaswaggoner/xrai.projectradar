Version: 4.1

## Overview

RabbitMQ comes with default built-in settings. Those can be entirely sufficient in some environment (e.g. development and QA). For all other cases, as well as [production deployment tuning](https://www.rabbitmq.com/docs/production-checklist), there is a way to configure many things in the broker as well as [plugins](https://www.rabbitmq.com/docs/plugins).

This guide covers a number of topics related to configuration:

- [Different ways](https://www.rabbitmq.com/docs/#means-of-configuration) in which various settings of the server and plugins are configured
- [Configuration file(s)](https://www.rabbitmq.com/docs/#configuration-files): primary [rabbitmq.conf](https://www.rabbitmq.com/docs/#config-file) or [a directory of.conf files](https://www.rabbitmq.com/docs/#config-confd-directory), and optional [advanced.config](https://www.rabbitmq.com/docs/#advanced-config-file)
- Default [configuration file location(s)](https://www.rabbitmq.com/docs/#config-location) on various platforms
- Configuration troubleshooting: how to [find config file location](https://www.rabbitmq.com/docs/#verify-configuration-config-file-location) and [inspect and verify effective configuration](https://www.rabbitmq.com/docs/#verify-configuration-effective-configuration)
- [Environment variable interpolation](https://www.rabbitmq.com/docs/#env-variable-interpolation) in `rabbitmq.conf`
- [Environment variables](https://www.rabbitmq.com/docs/#customise-environment) used by RabbitMQ nodes
- [Operating system (kernel) limits](https://www.rabbitmq.com/docs/#kernel-limits)
- Available [core server settings](https://www.rabbitmq.com/docs/#config-items)
- Available [environment variables](https://www.rabbitmq.com/docs/#supported-environment-variables)
- How to [encrypt sensitive configuration values](https://www.rabbitmq.com/docs/#configuration-encryption)

and more.

Since configuration affects many areas of the system, including plugins, individual [documentation guides](https://www.rabbitmq.com/docs) dive deeper into what can be configured. [Runtime Tuning](https://www.rabbitmq.com/docs/runtime) is a companion to this guide that focuses on the configurable parameters in the runtime. [Deployment Guidelines](https://www.rabbitmq.com/docs/production-checklist) is a related guide that outlines what settings will likely need tuning in most production environments.

## Means of Configuration

A RabbitMQ node can be configured using a number of mechanisms responsible for different areas:

| **Mechanism** | **Description** |
| --- | --- |
| [Configuration File(s)](https://www.rabbitmq.com/docs/#configuration-files) | Contains server and plugin settings for TCP listeners and other [networking-related settings](https://www.rabbitmq.com/docs/networking),[TLS](https://www.rabbitmq.com/docs/ssl), [resource constraints (alarms)](https://www.rabbitmq.com/docs/alarms), [authentication and authorisation backends](https://www.rabbitmq.com/docs/access-control),[message store settings](https://www.rabbitmq.com/docs/persistence-conf), and more. |
| [Environment Variables](https://www.rabbitmq.com/docs/#customise-environment) | Used to define [node name](https://www.rabbitmq.com/docs/cli#node-names), file and directory locations, runtime flags taken from the shell, or set in the environment configuration file, `rabbitmq-env.conf` (Linux, MacOS, BSD) and `rabbitmq-env-conf.bat` (Windows) |
| [rabbitmqctl](https://www.rabbitmq.com/docs/cli) | When [internal authentication/authorisation backend](https://www.rabbitmq.com/docs/access-control) is used,`rabbitmqctl` is the tool that manages virtual hosts, users and permissions. It is also used to manage [runtime parameters and policies](https://www.rabbitmq.com/docs/parameters). |
| [rabbitmq-queues](https://www.rabbitmq.com/docs/cli) | `rabbitmq-queues` is the tool that manages settings specific to [quorum queues](https://www.rabbitmq.com/docs/quorum-queues). |
| [rabbitmq-plugins](https://www.rabbitmq.com/docs/cli) | `rabbitmq-plugins` is the tool that manages [plugins](https://www.rabbitmq.com/docs/plugins). |
| [rabbitmq-diagnostics](https://www.rabbitmq.com/docs/cli) | `rabbitmq-diagnostics` allows for inspection of node state, including effective configuration, as well as many other metrics and [health checks](https://www.rabbitmq.com/docs/monitoring). |
| [Parameters and Policies](https://www.rabbitmq.com/docs/parameters) | defines cluster-wide settings which can change at run time as well as settings that are convenient to configure for groups of queues (exchanges, etc) such as including optional queue arguments. |
| [Runtime (Erlang VM) Flags](https://www.rabbitmq.com/docs/runtime) | Control lower-level aspects of the system: memory allocation settings, inter-node communication buffer size, runtime scheduler settings and more. |
| [Operating System Kernel Limits](https://www.rabbitmq.com/docs/#kernel-limits) | Control process limits enforced by the kernel: [max open file handle limit](https://www.rabbitmq.com/docs/networking#open-file-handle-limit), max number of processes and kernel threads, max resident set size and so on. |

Most settings are configured using the first two methods. This guide, therefore, focuses on them.

## Configuration File(s)

### Introduction

While some settings in RabbitMQ can be tuned using environment variables, most are configured using a [main configuration file](https://www.rabbitmq.com/docs/#config-file) named `rabbitmq.conf`.

This includes configuration for the core server as well as plugins. An additional configuration file can be used to configure settings that cannot be expressed in the main file's configuration format. This is covered in more details below.

The sections below cover the syntax and [location](https://www.rabbitmq.com/docs/#config-file-location) of both files, where to find examples, and more.

### Config File Locations

[Default config file locations](https://www.rabbitmq.com/docs/configure#config-location) vary between operating systems and [package types](https://www.rabbitmq.com/docs/download).

This topic is covered in more detail in the rest of this guide.

When in doubt about RabbitMQ config file location, consult the log file and/or management UI as explained in the following section.

### How to Find Config File Location

The active configuration file can be verified by inspecting the RabbitMQ log file. It will show up in the [log file](https://www.rabbitmq.com/docs/logging) at the top, along with the other broker boot log entries. For example:

```markdown
node           : rabbit@example
home dir       : /var/lib/rabbitmq
config file(s) : /etc/rabbitmq/advanced.config
               : /etc/rabbitmq/rabbitmq.conf
```

If the configuration file cannot be found or read by RabbitMQ, the log entry will say so:

```markdown
node           : rabbit@example
home dir       : /var/lib/rabbitmq
config file(s) : /var/lib/rabbitmq/hare.conf (not found)
```

Alternatively, the location of configuration files used by a local node, use the [rabbitmq-diagnostics status](https://www.rabbitmq.com/docs/man/rabbitmq-diagnostics.8) command:

```bash
# displays key
rabbitmq-diagnostics status
```

and look for the `Config files` section that would look like this:

```markdown
Config files

 * /etc/rabbitmq/advanced.config
 * /etc/rabbitmq/rabbitmq.conf
```

To inspect the locations of a specific node, including nodes running remotely, use the `-n` (short for `--node`) switch:

```bash
rabbitmq-diagnostics status -n [node name]
```

Finally, config file location can be found in the [management UI](https://www.rabbitmq.com/docs/management), together with other details about nodes.

When troubleshooting configuration settings, it is very useful to verify that the config file path is correct, exists and can be loaded (e.g. the file is readable) before [verifying effective node configuration](https://www.rabbitmq.com/docs/#verify-configuration-effective-configuration). Together, these steps help quickly narrow down most common misconfiguration problems.

### The Modern and Old Config File Formats

All [supported RabbitMQ versions](https://www.rabbitmq.com/release-information) use an [ini-like, sysctl configuration file format](https://www.rabbitmq.com/docs/#config-file) for the main configuration file. The file is typically named `rabbitmq.conf`.

The new config format is much simpler, easier for humans to read and machines to generate. It is also relatively limited compared to the classic config format used prior to RabbitMQ 3.7.0. For example, when configuring [LDAP support](https://www.rabbitmq.com/docs/ldap), it may be necessary to use deeply nested data structures to express desired configuration.

To accommodate this need, modern RabbitMQ versions allow for both formats to be used at the same time in separate files: `rabbitmq.conf` uses the new style format and is recommended for most settings, and `advanced.config` covers more advanced settings that the ini-style configuration cannot express. This is covered in more detail in the following sections.

| **Configuration File** | **Format Used** | **Purpose** |
| --- | --- | --- |
| `rabbitmq.conf` | New style format (sysctl or ini-like) | [Primary configuration file](https://www.rabbitmq.com/docs/#config-file) with a `.conf` extension. Should be used for most settings. It is easier for humans to read and machines (deployment tools) to generate. Not every setting can be expressed in this format. |
| `advanced.config` | Classic (Erlang terms) | A limited number of settings that cannot be expressed in the new style configuration format, such as [LDAP queries](https://www.rabbitmq.com/docs/ldap). Only should be used when necessary. |
| `rabbitmq-env.conf` (`rabbitmq-env.conf.bat` on Windows) | Environment variable pairs | Used to set [environment variables](https://www.rabbitmq.com/docs/#customise-environment) relevant to RabbitMQ in one place. |

Compare this examplary `rabbitmq.conf` file

```markdown
# A new style format snippet. This format is used by rabbitmq.conf files.
ssl_options.cacertfile           = /path/to/ca_certificate.pem
ssl_options.certfile             = /path/to/server_certificate.pem
ssl_options.keyfile              = /path/to/server_key.pem
ssl_options.verify               = verify_peer
ssl_options.fail_if_no_peer_cert = true
```

to

```erlang
%% A classic format snippet, now used by advanced.config files.
[
  {rabbit, [{ssl_options, [{cacertfile,           "/path/to/ca_certificate.pem"},
                           {certfile,             "/path/to/server_certificate.pem"},
                           {keyfile,              "/path/to/server_key.pem"},
                           {verify,               verify_peer},
                           {fail_if_no_peer_cert, true}]}]}
].
```

### The Main Configuration File, rabbitmq.conf

The configuration file `rabbitmq.conf` allows the RabbitMQ server and plugins to be configured. The file uses the [sysctl format](https://github.com/basho/cuttlefish/wiki/Cuttlefish-for-Application-Users), unlike `advanced.config` and the original `rabbitmq.config` (both use the Erlang terms format).

The syntax can be briefly explained like so:

- One setting uses one line
- Lines are structured `Key = Value`
- Any content starting with a `#` character is a comment
- Values that contain the `#` character, such as generated strings, generated passwords, encrypted values, and so on, can be escaped with single quotes like so: `'efd3!53a9@92#a08_d_6d'`

A minimalistic example configuration file follows:

```markdown
# this is a comment
listeners.tcp.default = 5673
```

The above example is equivalent to the following [classic config format](https://www.rabbitmq.com/docs/#config-file-formats):

```erlang
%% this is a comment
[
  {rabbit, [
      {tcp_listeners, [5673]}
    ]
  }
].
```

This example will alter the [port RabbitMQ listens on](https://www.rabbitmq.com/docs/networking#ports) for AMQP 0-9-1 and AMQP 1.0 client connections from 5672 to 5673.

A minimalistic example that uses value escaping:

```markdown
# this is a comment
default_user = '40696e180b610ed9'
default_pass = 'efd3!53a9@_2#a08'
```

which is equivalent to the following [classic config format](https://www.rabbitmq.com/docs/#config-file-formats):

```erlang
%% this is a comment
[
  {rabbit, [
      {default_user, <<"40696e180b610ed9">>},
      {default_pass, <<"efd3!53a9@_2#a08">>}
    ]
  }
].
```

The RabbitMQ server source repository contains [an example rabbitmq.conf file](https://github.com/rabbitmq/rabbitmq-server/blob/main/deps/rabbit/docs/rabbitmq.conf.example) named `rabbitmq.conf.example`. It contains examples of most of the configuration items you might want to set (with some very obscure ones omitted), along with documentation for those settings.

Documentation guides such as [Networking](https://www.rabbitmq.com/docs/networking), [TLS](https://www.rabbitmq.com/docs/ssl), or [Access Control](https://www.rabbitmq.com/docs/access-control) contain many examples in relevant formats.

Note that this configuration file is not to be confused with the environment variable configuration files, [rabbitmq-env.conf](https://www.rabbitmq.com/docs/#environment-env-file-unix) and [rabbitmq-env-conf.bat](https://www.rabbitmq.com/docs/#rabbitmq-env-file-windows).

To override the main RabbitMQ config file location, use the `RABBITMQ_CONFIG_FILE` (or `RABBITMQ_CONFIG_FILES` to use a `conf.d` -style directory of sorted files) [environment variables](https://www.rabbitmq.com/docs/#customise-environment). Use `.conf` as file extension for the new style config format, e.g. `/etc/rabbitmq/rabbitmq.conf` or `/data/configuration/rabbitmq/rabbitmq.conf`

### Value Escaping

Values that contain the `#` character, usually machine-generated, can be escaped with single quotes:

```markdown
# escaping is not necessary here but may be a good idea for generated
# values
default_user = '7f11ddc4f1900a233964'
# escaping is important here as without it,
# the # character and everything that follows it would be
# considered a comment
default_pass = 'efd3!53a9@92#a08_d_6d'
```

### Using a Directory of.conf Files

A `conf.d` -style directory of files can also be used. Use `RABBITMQ_CONFIG_FILES` (note the plural "\_FILES") to point the node at a directory of such files:

```markdown
# uses a directory of .conf files loaded in alphabetical order
RABBITMQ_CONFIG_FILES=/path/to/a/custom/location/rabbitmq/conf.d
```

Target directory must contain a number of `.conf` files with the same syntax as `rabbitmq.conf`.

They will be **loaded in alphabetical order**. A common naming practice uses numerical prefixes in filenames to make it easier to reason about the order, or make sure a "defaults file" is always loaded first, regardless of how many extra files are generated at deployment time:

```bash
ls -lh /path/to/a/custom/location/rabbitmq/conf.d
# => -r--r--r--  1 rabbitmq  rabbitmq    87B Mar 21 19:50 00-defaults.conf
# => -r--r--r--  1 rabbitmq  rabbitmq   4.6K Mar 21 19:52 10-main.conf
# => -r--r--r--  1 rabbitmq  rabbitmq   1.6K Mar 21 19:52 20-tls.conf
# => -r--r--r--  1 rabbitmq  rabbitmq   1.6K Mar 21 19:52 30-federation.conf
```

### Environment Variable Interpolation in rabbitmq.conf

[Modern RabbitMQ versions](https://www.rabbitmq.com/release-information) support environment variable interpolation in `rabbitmq.conf`. For example, to override default user credentials, one can use [import a definition file](https://www.rabbitmq.com/docs/definitions) or the following config file in combination with two environment variables:

```markdown
# environment variable interpolation
default_user = $(SEED_USERNAME)
default_pass = $(SEED_USER_PASSWORD)
```

Environment variables can be used to configure a portion of a value, for example, cluster name:

```markdown
cluster_name = deployment-$(DEPLOYMENT_ID)
```

Environment variable values are interpolated as strings before the config file is parsed and validated. This means that they can be used to override numerical settings (such as ports) or paths (such as TLS certificate and private key paths).

In addition, RabbitMQ respects a [number of environment variables](https://www.rabbitmq.com/docs/#customise-environment) for when a value must be known before the configuration file is loaded.

### The advanced.config File

Some configuration settings are not possible or are difficult to configure using the sysctl format. As such, it is possible to use an additional config file in the Erlang term format (same as `rabbitmq.config`). That file is commonly named `advanced.config`. It will be merged with the configuration provided in `rabbitmq.conf`.

The RabbitMQ server source repository contains [an example advanced.config file](https://github.com/rabbitmq/rabbitmq-server/blob/v3.13.x/deps/rabbit/docs/advanced.config.example) named `advanced.config.example`. It focuses on the options that are typically set using the advanced config.

To override the advanced config file location, use the `RABBITMQ_ADVANCED_CONFIG_FILE` environment variable.

### Location of rabbitmq.conf, advanced.config and rabbitmq-env.conf

Default configuration file location is distribution-specific. RabbitMQ packages or nodes will not create any configuration files. Users and deployment tool should use the following locations when creating the files:

| **Platform** | **Default Configuration File Directory** | **Example Configuration File Paths** |
| --- | --- | --- |
| [Generic binary package](https://www.rabbitmq.com/docs/install-generic-unix) | `$RABBITMQ_HOME/etc/rabbitmq/` | `$RABBITMQ_HOME/etc/rabbitmq/rabbitmq.conf`,`$RABBITMQ_HOME/etc/rabbitmq/advanced.config` |
| [Debian and Ubuntu](https://www.rabbitmq.com/docs/install-debian) | `/etc/rabbitmq/` | `/etc/rabbitmq/rabbitmq.conf`,`/etc/rabbitmq/advanced.config` |
| [RPM-based Linux](https://www.rabbitmq.com/docs/install-rpm) | `/etc/rabbitmq/` | `/etc/rabbitmq/rabbitmq.conf`,`/etc/rabbitmq/advanced.config` |
| [Windows](https://www.rabbitmq.com/docs/install-windows) | `%APPDATA%\RabbitMQ\` | `%APPDATA%\RabbitMQ\rabbitmq.conf`,`%APPDATA%\RabbitMQ\advanced.config` |
| [MacOS Homebrew Formula](https://www.rabbitmq.com/docs/install-homebrew) | `${install_prefix}/etc/rabbitmq/`, and the Homebrew cellar prefix is usually `/usr/local` | `${install_prefix}/etc/rabbitmq/rabbitmq.conf`,`${install_prefix}/etc/rabbitmq/advanced.config` |

Environment variables can be used to override the location of the configuration file:

```markdown
# overrides primary config file location
RABBITMQ_CONFIG_FILE=/path/to/a/custom/location/rabbitmq.conf

# overrides advanced config file location
RABBITMQ_ADVANCED_CONFIG_FILE=/path/to/a/custom/location/advanced.config

# overrides environment variable file location
RABBITMQ_CONF_ENV_FILE=/path/to/a/custom/location/rabbitmq-env.conf
```

### When Will Configuration File Changes Be Applied

`rabbitmq.conf` and `advanced.config` changes take effect after a node restart.

If `rabbitmq-env.conf` doesn't exist, it can be created manually in the location specified by the `RABBITMQ_CONF_ENV_FILE` variable. On Windows systems, it is named `rabbitmq-env-conf.bat`.

Windows service users will need to **[re-install the service](https://www.rabbitmq.com/docs/#rabbitmq-env-file-windows)** if configuration file location or any values in \`\`rabbitmq-env-conf.bat\` have changed. Environment variables used by the service would not be updated otherwise.

In the context of deployment automation this means that environment variables such as `RABBITMQ_BASE` and `RABBITMQ_CONFIG_FILE` should ideally be set before RabbitMQ is installed. This would help avoid unnecessary confusion and Windows service re-installations.

### How to Inspect and Verify Effective Configuration of a Running Node

It is possible to print effective configuration (user provided values from all configuration files merged into defaults) using the [rabbitmq-diagnostics environment](https://www.rabbitmq.com/docs/man/rabbitmq-diagnostics.8) command:

```bash
# inspect effective configuration on a node
rabbitmq-diagnostics environment
```

to check effective configuration of a specific node, including nodes running remotely, use the `-n` (short for `--node`) switch:

```bash
rabbitmq-diagnostics environment -n [node name]
```

The command above will print applied configuration for every application (RabbitMQ, plugins, libraries) running on the node. Effective configuration is computed using the following steps:

- `rabbitmq.conf` is translated into the internally used (advanced) config format. These configuration is merged into the defaults
- `advanced.config` is loaded if present, and merged into the result of the step above

Effective configuration should be verified together with [config file location](https://www.rabbitmq.com/docs/#verify-configuration-config-file-location). Together, these steps help quickly narrow down most common misconfiguration problems.

### The rabbitmq.config (Classic Format) File

Prior to RabbitMQ 3.7.0, RabbitMQ config file was named `rabbitmq.config` and used [the same Erlang term format](http://www.erlang.org/doc/man/config.html) used by `advanced.config` today. That format is [still supported](https://www.rabbitmq.com/docs/#config-file-formats) for backwards compatibility.

The classic format is **deprecated**. Please prefer the [new style config format](https://www.rabbitmq.com/docs/#config-file) in `rabbitmq.conf` accompanied by an `advanced.config` file as needed.

To use a config file in the classic format, export `RABBITMQ_CONFIG_FILE` to point to the file with a `.config` extension. The extension will indicate to RabbitMQ that it should treat the file as one in the classic config format.

[An example configuration file](https://github.com/rabbitmq/rabbitmq-server/blob/v3.7.x/deps/rabbit/docs/rabbitmq.config.example) named `rabbitmq.config.example`. It contains an example of most of the configuration items in the classic config format.

To override the main RabbitMQ config file location, use the `RABBITMQ_CONFIG_FILE` [environment variable](https://www.rabbitmq.com/docs/#customise-environment). Use `.config` as file extension for the classic config format.

The use of classic config format should only be limited to the [advanced.config file](https://www.rabbitmq.com/docs/#advanced-config-file) and settings that cannot be configured using the [ini-style config file](https://www.rabbitmq.com/docs/#config-file).

### Example Configuration Files

The RabbitMQ server source repository contains examples for the configuration files:

- [rabbitmq.conf.example](https://github.com/rabbitmq/rabbitmq-server/blob/main/deps/rabbit/docs/rabbitmq.conf.example)
- [advanced.config.example](https://github.com/rabbitmq/rabbitmq-server/blob/main/deps/rabbit/docs/advanced.config.example)

These files contain examples of most of the configuration keys along with a brief explanation for those settings. All configuration items are commented out in the example, so you can uncomment what you need. Note that the example files are meant to be used as, well, examples, and should not be treated as a general recommendation.

In most distributions the example file is placed into the same location as the real file should be placed (see above). On Debian and RPM distributions policy forbids doing so; instead find the file under `/usr/share/doc/rabbitmq-server/` or `/usr/share/doc/rabbitmq-server-4.1.2/`, respectively.

### Core Server Variables Configurable in rabbitmq.conf

These variables are the most common. The list is not complete, as some settings are quite obscure.

| **Key** | **Documentation** |
| --- | --- |
| `listeners.tcp` | Ports or hostname/pair on which to listen for "plain" AMQP 0-9-1 and AMQP 1.0 connections (without [TLS](https://www.rabbitmq.com/docs/ssl)). See the [Networking guide](https://www.rabbitmq.com/docs/networking) for more details and examples.  Default:  ```markdown listeners.tcp.default = 5672 ``` |
| `listeners.ssl` | Ports or hostname/pair on which to listen for TLS-enabled AMQP 0-9-1 and AMQP 1.0 connections. See the [TLS guide](https://www.rabbitmq.com/docs/ssl) for more details and examples.  Default: `none` (not set) |
| `ssl_options` | TLS configuration. See the [TLS guide](https://www.rabbitmq.com/docs/ssl#enabling-tls).  Default:  ```markdown ssl_options = none ``` |
| `num_acceptors.tcp` | Number of Erlang processes that will accept connections for the TCP listeners.  Default:  ```markdown num_acceptors.tcp = 10 ``` |
| `num_acceptors.ssl` | Number of Erlang processes that will accept TLS connections from clients.  Default:  ```markdown num_acceptors.ssl = 10 ``` |
| `distribution.listener.interface` | Controls what network interface will be used for communication with other cluster members and CLI tools.  Default:  ```markdown distribution.listener.interface = 0.0.0.0 ``` |
| `distribution.listener.port_range.min` | Controls the lower bound of a server port range that will be used for communication with other cluster members and CLI tools.  Default:  ```markdown distribution.listener.port_range.min = 25672 ``` |
| `distribution.listener.port_range.max` | Controls the upper bound of a server port range that will be used for communication with other cluster members and CLI tools.  Default:  ```markdown distribution.listener.port_range.max = 25672 ``` |
| `handshake_timeout` | Maximum time for AMQP 0-9-1 handshake (after socket connection and TLS handshake), in milliseconds.  Default:  ```markdown handshake_timeout = 10000 ``` |
| `ssl_handshake_timeout` | TLS handshake timeout, in milliseconds.  Default:  ```markdown ssl_handshake_timeout = 5000 ``` |
| `vm_memory_high_watermark` | Memory threshold at which the flow control is triggered. Can be absolute or relative to the amount of RAM available to the OS:  ```markdown vm_memory_high_watermark.relative = 0.7 ``` ```markdown vm_memory_high_watermark.absolute = 2GB ```  See the [memory-based flow control](https://www.rabbitmq.com/docs/memory) and [alarms](https://www.rabbitmq.com/docs/alarms) documentation.  Default:  ```markdown vm_memory_high_watermark.relative = 0.6 ``` |
| `vm_memory_calculation_strategy` | Strategy for memory usage reporting. Can be one of the following:  - `allocated`: uses Erlang memory allocator statistics - `rss`: uses operating system RSS memory reporting. This uses OS-specific means and may start short lived child processes. - `legacy`: uses legacy memory reporting (how much memory is considered to be used by the runtime). This strategy is fairly inaccurate. - `erlang`: same as `legacy`, preserved for backwards compatibility  Default:  ```markdown vm_memory_calculation_strategy = rss ``` |
| `total_memory_available_override_value` | Makes it possible to override the total amount of memory available, as opposed to inferring it from the environment using OS-specific means. This should only be used when actual maximum amount of RAM available to the node doesn't match the value that will be inferred by the node, e.g. due to containerization or similar constraints the node cannot be aware of. The value may be set to an integer number of bytes or, alternatively, in information units (e.g `8GB`). For example, when the value is set to 4 GB, the node will believe it is running on a machine with 4 GB of RAM.  Default: `undefined` (not set or used). |
| `disk_free_limit` | Disk free space limit of the partition on which RabbitMQ is storing data. When available disk space falls below this limit, flow control is triggered. The value can be set relative to the total amount of RAM or as an absolute value in bytes or, alternatively, in information units (e.g `50MB` or `5GB`):  ```markdown disk_free_limit.absolute = 2GB ```  By default free disk space must exceed 50MB. This must be revisited for [production environments](https://www.rabbitmq.com/docs/production-checklist). See the [Disk Alarms](https://www.rabbitmq.com/docs/disk-alarms) documentation.  Default:  ```markdown disk_free_limit.absolute = 50MB ``` |
| `queue_leader_locator` | Controls the [strategy used when selecting a node](https://www.rabbitmq.com/docs/clustering#replica-placement) to host the leader replica of a newly declared queue or stream. |
| `log.file.level` | Controls the granularity of logging. The value is a list of log event category and log level pairs.  The level can be one of `error` (only errors are logged), `warning` (only errors and warning are logged), `info` (errors, warnings and informational messages are logged), or `debug` (errors, warnings, informational messages and debugging messages are logged).  Default:  ```markdown log.file.level = info ``` |
| `session_max_per_connection` | Maximum number of AMQP 1.0 sessions that can be simultaneously active on an AMQP 1.0 connection.  Default: `64`  Min value: `1`  Max value: `65535` |
| `link_max_per_session` | Maximum number of AMQP 1.0 links that can be simultaneously active on an AMQP 1.0 session.  Default: `256`  Min value: `1`  Max value: `4294967295` |
| `channel_max` | Maximum permissible number of channels to negotiate with clients, not including a special channel number 0 used in the protocol. Setting to 0 means "unlimited", a dangerous value since applications sometimes have channel leaks. Using more channels increases memory footprint of the broker.  Default:  ```markdown channel_max = 2047 ``` |
| `channel_operation_timeout` | Channel operation timeout in milliseconds (used internally, not directly exposed to clients due to messaging protocol differences and limitations).  Default:  ```markdown channel_operation_timeout = 15000 ``` |
| `max_message_size` | The largest allowed message payload size in bytes. Messages of larger size will be rejected with a suitable channel exception.  Default: `16777216`  Max value: `536870912` |
| `heartbeat` | Value representing the heartbeat timeout suggested by the server during connection parameter negotiation. If set to 0 on both ends, heartbeats are deactivated (this is not recommended). See the [Heartbeats guide](https://www.rabbitmq.com/docs/heartbeats) for details.  Default:  ```markdown heartbeat = 60 ``` |
| `default_vhost` | Virtual host to create when RabbitMQ creates a new database from scratch. The exchange `amq.rabbitmq.log` will exist in this virtual host.  Default:  ```markdown default_vhost = / ``` |
| `default_user` | User name to create when RabbitMQ creates a new database from scratch.  Default:  ```markdown default_user = guest ``` |
| `default_pass` | Password for the default user.  Default:  ```markdown default_pass = guest ``` |
| `default_user_tags` | Tags for the default user.  Default:  ```markdown default_user_tags.administrator = true ``` |
| `default_permissions` | [Permissions](https://www.rabbitmq.com/docs/access-control) to assign to the default user when creating it.  Default:  ```markdown default_permissions.configure = .* default_permissions.read = .* default_permissions.write = .* ``` |
| `loopback_users` | List of users which are only permitted to connect to the broker via a loopback interface (i.e. `localhost`).  To allow the default `guest` user to connect remotely (a security practice [unsuitable for production use](https://www.rabbitmq.com/docs/production-checklist)), set this to `none`:  ```markdown # awful security practice, # consider creating a new # user with secure generated credentials! loopback_users = none ```  To restrict another user to localhost-only connections, do it like so (`monitoring` is the name of the user):  ```markdown loopback_users.monitoring = true ```  Default:  ```markdown # guest uses well known # credentials and can only # log in from localhost # by default loopback_users.guest = true ``` |
| `cluster_formation.classic_config.nodes` | Classic [peer discovery](https://www.rabbitmq.com/docs/cluster-formation) backend's list of nodes to contact.  For example, to cluster with nodes `rabbit@hostname1` and `rabbit@hostname2` on first boot:  ```markdown cluster_formation.classic_config.nodes.1 = rabbit@hostname1 cluster_formation.classic_config.nodes.2 = rabbit@hostname2 ```  Default: `none` (not set) |
| `collect_statistics` | Statistics collection mode. Primarily relevant for the management plugin. Options are:  - `none` (do not emit statistics events) - `coarse` (emit per-queue / per-channel / per-connection statistics) - `fine` (also emit per-message statistics)  Default:  ```markdown collect_statistics = none ``` |
| `collect_statistics_interval` | Statistics collection interval in milliseconds. Primarily relevant for the [management plugin](https://www.rabbitmq.com/docs/management#statistics-interval).  Default:  ```markdown collect_statistics_interval = 5000 ``` |
| `management.db_cache_multiplier` | Affects the amount of time the [management plugin](https://www.rabbitmq.com/docs/management#statistics-interval) will cache expensive management queries such as queue listings. The cache will multiply the elapsed time of the last query by this value and cache the result for this amount of time.  Default:  ```markdown management.db_cache_multiplier = 5 ``` |
| `auth_mechanisms` | [SASL authentication mechanisms](https://www.rabbitmq.com/docs/authentication) to offer to clients.  Default:  ```markdown # see the Access Control guide to learn more auth_mechanisms.1 = PLAIN auth_mechanisms.2 = AMQPLAIN # see the Access Control and Deployment Guidelines guides to learn more auth_mechanisms.3 = ANONYMOUS ``` |
| `auth_backends` | List of [authentication and authorisation backends](https://www.rabbitmq.com/docs/access-control) to use. See the [access control guide](https://www.rabbitmq.com/docs/access-control) for details and examples.  Other databases than `rabbit_auth_backend_internal` are available through [plugins](https://www.rabbitmq.com/docs/plugins).  Default:  ```markdown auth_backends.1 = internal ``` |
| `reverse_dns_lookups` | Set to `true` to have RabbitMQ perform a reverse DNS lookup on client connections, and present that information through `rabbitmqctl` and the management plugin.  Default:  ```markdown reverse_dns_lookups = false ``` |
| `delegate_count` | Number of delegate processes to use for intra-cluster communication. On a machine which has a very large number of cores and is also part of a cluster, you may wish to increase this value.  Default:  ```markdown delegate_count = 16 ``` |
| `tcp_listen_options` | Default socket options. You may want to change these when you troubleshoot network issues.  Default:  ```markdown tcp_listen_options.backlog = 128 tcp_listen_options.nodelay = true tcp_listen_options.linger.on = true tcp_listen_options.linger.timeout = 0 ```     ```markdown tcp_listen_options.exit_on_close = false ```  Set `tcp_listen_options.exit_on_close` to `true` to have RabbitMQ try to immediately close TCP socket when client disconnects. Note that this cannot guarantee immediate TCP socket resource release by the kernel.     ```markdown tcp_listen_options.keepalive = false ```  Set `tcp_listen_options.keepalive` to `true` to enable [TCP keepalives](https://www.rabbitmq.com/docs/networking#tcp-keepalives). |
| `cluster_partition_handling` | How to handle network partitions. Available modes are:  - `ignore` - `autoheal` - `pause_minority` - `pause_if_all_down`  `pause_if_all_down` mode requires additional parameters:  - `nodes` - `recover`  See the [documentation on partitions](https://www.rabbitmq.com/docs/partitions#automatic-handling) for more information.  Default:  ```markdown cluster_partition_handling = ignore ``` |
| `cluster_keepalive_interval` | How frequently nodes should send keepalive messages to other nodes (in milliseconds). Note that this is not the same thing as [`net_ticktime`](https://www.rabbitmq.com/docs/nettick); missed keepalive messages will not cause nodes to be considered down.  Default:  ```markdown cluster_keepalive_interval = 10000 ``` |
| `queue_index_embed_msgs_below` | Size in bytes of message below which messages will be embedded directly in the queue index. You are advised to read the [persister tuning](https://www.rabbitmq.com/docs/persistence-conf) documentation before changing this.  Default:  ```markdown queue_index_embed_msgs_below = 4096 ``` |
| `mnesia_table_loading_retry_timeout` | Timeout used when waiting for Mnesia tables in a cluster to become available.  Default:  ```markdown mnesia_table_loading_retry_timeout = 30000 ``` |
| `mnesia_table_loading_retry_limit` | Retries when waiting for Mnesia tables in the cluster startup. Note that this setting is not applied to Mnesia upgrades or node deletions.  Default:  ```markdown mnesia_table_loading_retry_limit = 10 ``` |
| `queue_leader_locator` | queue leader location strategy. Available strategies are:  - `balanced` - `client-local`  Default:  ```markdown queue_leader_locator = client-local ``` |
| `proxy_protocol` | If set to `true`, RabbitMQ will expect a [proxy protocol](http://www.haproxy.org/download/3.1/doc/proxy-protocol.txt) header to be sent first when an AMQP connection is opened. This implies to set up a proxy protocol-compliant reverse proxy (e.g. [HAproxy](http://www.haproxy.org/download/3.1/doc/proxy-protocol.txt) or [AWS ELB](http://docs.aws.amazon.com/elasticloadbalancing/latest/classic/enable-proxy-protocol.html)) in front of RabbitMQ. Clients can't directly connect to RabbitMQ when proxy protocol is enabled, so all connections must go through the reverse proxy.  See [the networking guide](https://www.rabbitmq.com/docs/networking#proxy-protocol) for more information.  Default:  ```markdown proxy_protocol = false ``` |
| `cluster_name` | Operator-controlled cluster name. This name is used to identify a cluster, and by the federation and Shovel plugins to record the origin or path of transferred messages. Can be set to any arbitrary string to help identify the cluster (eg. `london`). This name can be inspected by AMQP 0-9-1 clients in the server properties map.  Default: by default the name is derived from the first (seed) node in the cluster. |
| `node_tags` | A map of optional node tags (key-value pairs). |

The following configuration settings can be set in the [advanced config file](https://www.rabbitmq.com/docs/#advanced-config-file) only, under the `rabbit` section.

| **Key** | **Documentation** |
| --- | --- |
| `backing_queue_module` | Implementation module for queue contents.  Default:  ```erlang {rabbit, [ {backing_queue_module, rabbit_variable_queue} ]} ``` |
| `msg_store_file_size_limit` | Message store segment file size. Changing this for a node with an existing (initialised) database is dangerous and can lead to data loss!  Default: `16777216`  ```erlang {rabbit, [ %% Changing this for a node %% with an existing (initialised) database is dangerous and can %% lead to data loss! {msg_store_file_size_limit, 16777216} ]} ``` |
| `trace_vhosts` | Used internally by the [tracer](https://www.rabbitmq.com/docs/firehose). You shouldn't change this.  Default:  ```erlang {rabbit, [ {trace_vhosts, []} ]} ``` |
| `queue_index_max_journal_entries` | After how many queue index journal entries it will be flushed to disk.  Default:  ```erlang {rabbit, [ {queue_index_max_journal_entries, 32768} ]} ``` |

Several [plugins](https://www.rabbitmq.com/docs/plugins) that ship with RabbitMQ have dedicated documentation guides that cover plugin configuration:

- [rabbitmq\_management](https://www.rabbitmq.com/docs/management#configuration)
- [rabbitmq\_management\_agent](https://www.rabbitmq.com/docs/management#configuration)
- [rabbitmq\_stomp](https://www.rabbitmq.com/docs/stomp)
- [rabbitmq\_mqtt](https://www.rabbitmq.com/docs/mqtt)
- [rabbitmq\_shovel](https://www.rabbitmq.com/docs/shovel)
- [rabbitmq\_federation](https://www.rabbitmq.com/docs/federation)
- [rabbitmq\_auth\_backend\_ldap](https://www.rabbitmq.com/docs/ldap)
- [rabbitmq\_auth\_backend\_oauth](https://www.rabbitmq.com/docs/oauth2#variables-configurable)

### Cluster Name

By default, cluster name is set to the name of the first node in the cluster.

It can be overridden via `rabbitmq.conf`:

```markdown
cluster_name = americas.ca.1
```

RabbitMQ displays this value in the [management UI](https://www.rabbitmq.com/docs/management).

It can also be inspected by [listing global runtime parameters](https://www.rabbitmq.com/docs/parameters) and the `GET /api/global-parameters/cluster_name` [HTTP API endpoint](https://www.rabbitmq.com/docs/http-api-reference).

### Cluster Tags

Cluster tags are arbitrary key-value pairs that describe a cluster. They can be used by operators to attach deployment-specific information.

Cluster tags can be configured using `rabbitmq.conf`:

```markdown
cluster_tags.series = 4.1.x

cluster_tags.purpose = iot_ingress
cluster_tags.region = ca-central-1
cluster_tags.environment = production
```

To retrieve a list of tags, list [global runtime parameters](https://www.rabbitmq.com/docs/parameters) or fetch a global runtime parameter named `cluster_tags`, or use [`rabbitmqadmin` v2](https://www.rabbitmq.com/docs/management-cli) 's `snow overview` command.

### Node Tags

Node tags

Similarly to cluster tags, node tags can be preconfigured via `rabbitmq.conf`:

```markdown
node_tags.series = 4.1.x

node_tags.purpose = iot_ingress
node_tags.region = ca-central-1
node_tags.environment = production
```

Node tags can be inspected using CLI tools and the [HTTP API](https://www.rabbitmq.com/docs/http-api-reference).

## Configuration Value Encryption

Sensitive `advanced.config` and select `rabbitmq.conf` entries (e.g. password, URL containing credentials) can be encrypted. RabbitMQ nodes then decrypt encrypted entries on boot.

Note that encrypted configuration entries don't make the system meaningfully more secure. Nevertheless, they allow deployments of RabbitMQ to conform to regulations in various countries requiring that no sensitive data should appear in plain text in configuration files.

Encrypted values must be inside an Erlang `encrypted` tuple: `{encrypted, ...}`. Here is an example of a configuration file with an encrypted password for the default user:

```erlang
[
  {rabbit, [
      {default_user, <<"guest">>},
      {default_pass,
        {encrypted,
         <<"cPAymwqmMnbPXXRVqVzpxJdrS8mHEKuo2V+3vt1u/fymexD9oztQ2G/oJ4PAaSb2c5N/hRJ2aqP/X0VAfx8xOQ==">>
        }
      },
      {config_entry_decoder, [
             {passphrase, <<"mypassphrase">>}
         ]}
    ]}
].
```

Note the `config_entry_decoder` key with the passphrase that RabbitMQ will use to decrypt encrypted values.

The passphrase doesn't have to be hardcoded in the configuration file, it can be in a separate file:

```erlang
[
  {rabbit, [
      %% ...
      {config_entry_decoder, [
             {passphrase, {file, "/path/to/passphrase/file"}}
         ]}
    ]}
].
```

RabbitMQ can also request an operator to enter the passphrase when it starts by using `{passphrase, prompt}`.

### Encrypting advanced.config Values Using CLI Tools

Use [rabbitmqctl](https://www.rabbitmq.com/docs/cli) and the `encode` command to encrypt values:

```bash
# <<"guest">> here is a value to encode, as an Erlang binary,
# as it would have appeared in advanced.config
rabbitmqctl encode '<<"guest">>' mypassphrase
{encrypted,<<"... long encrypted value...">>}
# "amqp://fred:secret@host1.domain/my_vhost" here is a value to encode, provided as an Erlang string,
# as it would have appeared in advanced.config
rabbitmqctl encode '"amqp://fred:secret@host1.domain/my_vhost"' mypassphrase
{encrypted,<<"... long encrypted value...">>}
```

Or, on Windows:

```powershell
# <<"guest">> here is a value to encode, as an Erlang binary,
# as it would have appeared in advanced.config
rabbitmqctl encode "<<""guest"">>" mypassphrase
{encrypted,<<"... long encrypted value...">>}
# "amqp://fred:secret@host1.domain/my_vhost" here is a value to encode, provided as an Erlang string,
# as it would have appeared in advanced.config
rabbitmqctl encode '"amqp://fred:secret@host1.domain/my_vhost"' mypassphrase
{encrypted,<<"... long encrypted value...">>}
```

### Decrypting advanced.config Values Using CLI Tools

Use the `decode` command to decrypt values:

```bash
rabbitmqctl decode '{encrypted, <<"...">>}' mypassphrase
# => <<"guest">>
rabbitmqctl decode '{encrypted, <<"...">>}' mypassphrase
# => "amqp://fred:secret@host1.domain/my_vhost"
```

Or, on Windows:

```powershell
rabbitmqctl decode "{encrypted, <<""..."">>}" mypassphrase
# => <<"guest">>
rabbitmqctl decode "{encrypted, <<""..."">>}" mypassphrase
# => "amqp://fred:secret@host1.domain/my_vhost"
```

Values of different types can be encoded. The example above encodes both binaries (`<<"guest">>`) and strings (`"amqp://fred:secret@host1.domain/my_vhost"`).

### Encryption Settings: Cipher, Hashing Function, Number of Iterations

The encryption mechanism uses PBKDF2 to produce a derived key from the passphrase. The default hash function is SHA512 and the default number of iterations is 1000. The default cipher is AES 256 CBC.

These defaults can be changed in the configuration file:

```erlang
[
  {rabbit, [
      ...
      {config_entry_decoder, [
             {passphrase, "mypassphrase"},
             {cipher, blowfish_cfb64},
             {hash, sha256},
             {iterations, 10000}
         ]}
    ]}
].
```

Or, using [CLI tools](https://www.rabbitmq.com/docs/cli):

```bash
rabbitmqctl encode --cipher blowfish_cfb64 --hash sha256 --iterations 10000 \
                     '<<"guest">>' mypassphrase
```

Or, on Windows:

```powershell
rabbitmqctl encode --cipher blowfish_cfb64 --hash sha256 --iterations 10000 \
                     "<<""guest"">>" mypassphrase
```

### Using Encrypted Values in rabbitmq.conf and advanced.config

Encrypted values must be used as pairs, for example, if the encrypted value was returned as `<<"T9rCCHjY0ewlCWll8ux8vdynuAdA0/ji4koKh3eaziLfgigeW3K21VFzQZnvUxF0">>`, the value in `advanced.config` will look like this:

```markdown
{encrypted, <<"T9rCCHjY0ewlCWll8ux8vdynuAdA0/ji4koKh3eaziLfgigeW3K21VFzQZnvUxF0">>}
```

In, `rabbitmq.conf`, an encrypted value from the example above should be prefixed with `encrypted:`, that is:

```markdown
default_passowrd = encrypted:T9rCCHjY0ewlCWll8ux8vdynuAdA0/ji4koKh3eaziLfgigeW3K21VFzQZnvUxF0
```

When the `rabbitmq.conf` file is translated during node boot, the above value will be translated to `{encrypted, <<"T9rCCHjY0ewlCWll8ux8vdynuAdA0/ji4koKh3eaziLfgigeW3K21VFzQZnvUxF0">>}`, that is, the same value as used in `advanced.config`.

Value encryption is supposed for the following `rabbitmq.conf` keys:

- `ssl_options.password`
- `default_password`
- `default_user.$username.password`
- `definitions.tls.password`
- `anonymous_login_pass`

## Configuration Using Environment Variables

Certain server parameters can be configured using environment variables:[node name](https://www.rabbitmq.com/docs/cli#node-names), RabbitMQ [configuration file location](https://www.rabbitmq.com/docs/#configuration-files),[inter-node communication ports](https://www.rabbitmq.com/docs/networking#ports), Erlang VM flags, and so on.

### Path and Directory Name Restrictions

Some of the environment variable configure paths and locations (node's base or data directory, [plugin source and expansion directories](https://www.rabbitmq.com/docs/plugins), and so on). Those paths have must exclude a number of characters:

- `*` and `?` (on Linux, macOS, BSD and other UNIX-like systems)
- `^` and `!` (on Windows)
- `[` and `]`
- `{` and `}`

The above characters will render the node unable to start or function as expected (e.g. expand plugins and load their metadata).

### Linux, MacOS, BSD

On UNIX-based systems (Linux, MacOS and flavours of BSD) it is possible to use a file named `rabbitmq-env.conf` to define environment variables that will be used by the broker. Its [location](https://www.rabbitmq.com/docs/#config-location) is configurable using the `RABBITMQ_CONF_ENV_FILE` environment variable.

`rabbitmq-env.conf` uses the standard environment variable names but without the `RABBITMQ_` prefix. For example, the `RABBITMQ_CONFIG_FILE` variable appears below as `CONFIG_FILE` and `RABBITMQ_NODENAME` becomes `NODENAME`:

```bash
# Example rabbitmq-env.conf file entries. Note that the variables
# do not have the RABBITMQ_ prefix.
#
# Overrides node name
NODENAME=bunny@myhost

# Specifies new style config file location
CONFIG_FILE=/etc/rabbitmq/rabbitmq.conf

# Specifies advanced config file location
ADVANCED_CONFIG_FILE=/etc/rabbitmq/advanced.config
```

See the [rabbitmq-env.conf man page](https://www.rabbitmq.com/docs/man/rabbitmq-env.conf.5) for details.

### Windows

The easiest option to customise names, ports or locations is to configure environment variables in the Windows dialogue: Start > Settings > Control Panel > System > Advanced > Environment Variables. Then create or edit the system variable name and value.

Alternatively it is possible to use a file named `rabbitmq-env-conf.bat` to define environment variables that will be used by the broker. Its [location](https://www.rabbitmq.com/docs/#config-location) is configurable using the `RABBITMQ_CONF_ENV_FILE` environment variable.

Windows service users will need to **re-install the service** if configuration file location or any values in \`\`rabbitmq-env-conf.bat\` changed. Environment variables used by the service would not be updated otherwise.

This can be done using the installer or on the command line with administrator permissions:

- Start an [administrative command prompt](https://technet.microsoft.com/en-us/library/cc947813%28v=ws.10%29.aspx)
- cd into the sbin folder under the RabbitMQ server installation directory (such as `C:\Program Files (x86)\RabbitMQ Server\rabbitmq_server-{version}\sbin`)
- Run `rabbitmq-service.bat stop` to stop the service
- Run `rabbitmq-service.bat remove` to remove the Windows service (this will *not* remove RabbitMQ or its data directory)
- Set environment variables via command line, i.e. run commands like the following:
	```powershell
	set RABBITMQ_BASE=C:\Data\RabbitMQ
	```
- Run `rabbitmq-service.bat install`
- Run `rabbitmq-service.bat start`

This will restart the node in a way that makes the environment variable and `rabbitmq-env-conf.bat` changes to be observable to it.

## Environment Variables Used by RabbitMQ

All environment variables used by RabbitMQ use the prefix `RABBITMQ_` (except when defined in [rabbitmq-env.conf](https://www.rabbitmq.com/docs/#environment-env-file-unix) or [rabbitmq-env-conf.bat](https://www.rabbitmq.com/docs/#rabbitmq-env-file-windows)).

Environment variables set in the shell environment take priority over those set in [rabbitmq-env.conf](https://www.rabbitmq.com/docs/#environment-env-file-unix) or [rabbitmq-env-conf.bat](https://www.rabbitmq.com/docs/#rabbitmq-env-file-windows), which in turn override RabbitMQ built-in defaults.

The table below describes key environment variables that can be used to configure RabbitMQ. More variables are covered in the [File and Directory Locations guide](https://www.rabbitmq.com/docs/relocate).

| Name | Description |
| --- | --- |
| RABBITMQ\_NODE\_IP\_ADDRESS | Change this if you only want to bind to one network interface. Binding to two or more interfaces can be set up in the configuration file.  **Default**: an empty string, meaning "bind to all network interfaces". |
| RABBITMQ\_NODE\_PORT | See [Networking guide](https://www.rabbitmq.com/docs/networking) for more information on ports used by various parts of RabbitMQ.  **Default**: 5672. |
| RABBITMQ\_DIST\_PORT | Port used for inter-node and CLI tool communication. Ignored if node config file sets `kernel.inet_dist_listen_min` or `kernel.inet_dist_listen_max` keys. See [Networking](https://www.rabbitmq.com/docs/networking) for details, and [Windows Configuration](https://www.rabbitmq.com/docs/windows-configuration) for Windows-specific details.  **Default**: `RABBITMQ_NODE_PORT + 20000` |
| ERL\_MAX\_PORTS | This limit corresponds to the [maximum open file handle limit](https://www.rabbitmq.com/docs/networking#open-file-handle-limit) in the kernel. When the latter is set to a value higher than 65536, `ERL_MAX_PORT` must be adjusted accordingly.  **Default**: 65536 |
| ERL\_EPMD\_ADDRESS | Interface(s) used by [epmd](https://www.rabbitmq.com/docs/networking#epmd), a component in inter-node and CLI tool communication.  **Default**: all available interfaces, both IPv6 and IPv4. |
| ERL\_EPMD\_PORT | Port used by [epmd](https://www.rabbitmq.com/docs/networking#epmd), a component in inter-node and CLI tool communication.  **Default**: `4369` |
| RABBITMQ\_DISTRIBUTION\_BUFFER\_SIZE | [Outgoing data buffer size limit](https://erlang.org/doc/man/erl.html#+zdbbl) to use for inter-node communication connections, in kilobytes. Values lower than 64 MB are not recommended.  **Default**: 128000 |
| RABBITMQ\_NODENAME | The node name should be unique per Erlang-node-and-machine combination. To run multiple nodes, see the [clustering guide](https://www.rabbitmq.com/docs/clustering).  **Default**:  - **Unix*:*\* `rabbit@$HOSTNAME` - **Windows:**`rabbit@%COMPUTERNAME%` |
| RABBITMQ\_CONFIG\_FILE | Main RabbitMQ config file path, for example,`/etc/rabbitmq/rabbitmq.conf` or `/data/configuration/rabbitmq.conf` for new style configuration format files. If classic config format it used, the extension must be `.config`  **Default**:  - **Generic UNIX**: `$RABBITMQ_HOME/etc/rabbitmq/rabbitmq.conf` - **Debian**: `/etc/rabbitmq/rabbitmq.conf` - **RPM**: `/etc/rabbitmq/rabbitmq.conf` - **MacOS(Homebrew)**: `${install_prefix}/etc/rabbitmq/rabbitmq.conf`, the Homebrew prefix is usually `/usr/local` or `/opt/homebrew` - **Windows**: `%APPDATA%\RabbitMQ\rabbitmq.conf` |
| RABBITMQ\_CONFIG\_FILES | Path to a directory of RabbitMQ configuration files in the new-style (.conf) format. The files will be loaded in alphabetical order. Prefixing each files with a number is a common practice.  **Default**:  - **Generic UNIX**: `$RABBITMQ_HOME/etc/rabbitmq/conf.d` - **Debian**: `/etc/rabbitmq/conf.d` - **RPM**: `/etc/rabbitmq/conf.d` - **MacOS(Homebrew)**: `${install_prefix}/etc/rabbitmq/conf.d`, the Homebrew prefix is usually `/usr/local` or `/opt/homebrew` - **Windows**: `%APPDATA%\RabbitMQ\conf.d` |
| RABBITMQ\_ADVANCED\_CONFIG\_FILE | "Advanced" (Erlang term-based) RabbitMQ config file path with a `.config` file extension. For example, `/data/rabbitmq/advanced.config`.  **Default**:  - **Generic UNIX**: `$RABBITMQ_HOME/etc/rabbitmq/advanced.config` - **Debian**: `/etc/rabbitmq/advanced.config` - **RPM**: `/etc/rabbitmq/advanced.config` - **MacOS (Homebrew)**: `${install_prefix}/etc/rabbitmq/advanced.config`, the Homebrew prefix is usually `/usr/local` or `/opt/homebrew` - **Windows**: `%APPDATA%\RabbitMQ\advanced.config` |
| RABBITMQ\_CONF\_ENV\_FILE | Location of the file that contains environment variable definitions (without the `RABBITMQ_` prefix). Note that the file name on Windows is different from other operating systems.  **Default**:  - **Generic UNIX package**: `$RABBITMQ_HOME/etc/rabbitmq/rabbitmq-env.conf` - **Ubuntu and Debian**: `/etc/rabbitmq/rabbitmq-env.conf` - **RPM**: `/etc/rabbitmq/rabbitmq-env.conf` - **MacOS (Homebrew)**: `${install_prefix}/etc/rabbitmq/rabbitmq-env.conf`, the Homebrew prefix is usually `/usr/local` or `/opt/homebrew` - **Windows**: `%APPDATA%\RabbitMQ\rabbitmq-env-conf.bat` |
| RABBITMQ\_LOG\_BASE | Can be used to override log files directory location.  **Default**:  - **Generic UNIX package**: `$RABBITMQ_HOME/var/log/rabbitmq` - **Ubuntu and Debian** packages: `/var/log/rabbitmq` - **RPM**: `/var/log/rabbitmq` - **MacOS (Homebrew)**: `${install_prefix}/var/log/rabbitmq`, the Homebrew prefix is usually `/usr/local` or `/opt/homebrew` - **Windows**: `%APPDATA%\RabbitMQ\log` |
| RABBITMQ\_MNESIA\_BASE | This base directory contains sub-directories for the RabbitMQ server's node database, message store and cluster state files, one for each node, unless **RABBITMQ\_MNESIA\_DIR** is set explicitly. It is important that effective RabbitMQ user has sufficient permissions to read, write and create files and subdirectories in this directory at any time. This variable is typically not overridden. Usually `RABBITMQ_MNESIA_DIR` is overridden instead.  **Default**:  - **Generic UNIX package**: `$RABBITMQ_HOME/var/lib/rabbitmq/mnesia` - **Ubuntu and Debian** packages: `/var/lib/rabbitmq/mnesia/` - **RPM**: `/var/lib/rabbitmq/plugins` - **MacOS (Homebrew)**: `${install_prefix}/var/lib/rabbitmq/mnesia`, the Homebrew prefix is usually `/usr/local` or `/opt/homebrew` - **Windows**: `%APPDATA%\RabbitMQ` |
| RABBITMQ\_MNESIA\_DIR | The directory where this RabbitMQ node's data is stored. This includes a schema database, message stores, cluster member information and other persistent node state.  **Default**:  - **Generic UNIX package**: `$RABBITMQ_MNESIA_BASE/$RABBITMQ_NODENAME` - **Ubuntu and Debian** packages: `$RABBITMQ_MNESIA_BASE/$RABBITMQ_NODENAME` - **RPM**: `$RABBITMQ_MNESIA_BASE/$RABBITMQ_NODENAME` - **MacOS (Homebrew)**: `${install_prefix}/var/lib/rabbitmq/mnesia/$RABBITMQ_NODENAME`, the Homebrew prefix is usually `/usr/local` or `/opt/homebrew` - **Windows**: `%APPDATA%\RabbitMQ\$RABBITMQ_NODENAME` |
| RABBITMQ\_PLUGINS\_DIR | The list of directories where [plugin](https://www.rabbitmq.com/docs/plugins) archive files are located and extracted from. This is `PATH` -like variable, where different paths are separated by an OS-specific separator (`:` for Unix, `;` for Windows). Plugins can be [installed](https://www.rabbitmq.com/docs/plugins) to any of the directories listed here. Must not contain any characters mentioned in the [path restriction section](https://www.rabbitmq.com/docs/#directory-and-path-restrictions). See [CLI tools guide](https://www.rabbitmq.com/docs/cli#rabbitmq-plugins) to learn about the effects of changing this variable on `rabbitmq-plugins`.  **Default**:  - **Generic UNIX package**: `$RABBITMQ_HOME/plugins` - **Ubuntu and Debian** packages: `/var/lib/rabbitmq/plugins` - **RPM**: `/var/lib/rabbitmq/plugins` - **MacOS (Homebrew)**: `${install_prefix}/Cellar/rabbitmq/${version}/plugins`, the Homebrew prefix is usually `/usr/local` or `/opt/homebrew` - **Windows**: `%RABBITMQ_HOME%\plugins` |
| RABBITMQ\_PLUGINS\_EXPAND\_DIR | The directory the node expand (unpack) [plugins](https://www.rabbitmq.com/docs/plugins) to and use it as a code path location. Must not contain any characters mentioned in the [path restriction section](https://www.rabbitmq.com/docs/#directory-and-path-restrictions).  **Default**:  - **Generic UNIX package**: `$RABBITMQ_MNESIA_BASE/$RABBITMQ_NODENAME-plugins-expand` - **Ubuntu and Debian** packages: `$RABBITMQ_MNESIA_BASE/$RABBITMQ_NODENAME-plugins-expand` - **RPM**: `$RABBITMQ_MNESIA_BASE/$RABBITMQ_NODENAME-plugins-expand` - **MacOS (Homebrew)**:`${install_prefix}/var/lib/rabbitmq/mnesia/$RABBITMQ_NODENAME-plugins-expand` - **Windows**: `%APPDATA%\RabbitMQ\$RABBITMQ_NODENAME-plugins-expand` |
| RABBITMQ\_USE\_LONGNAME | When set to `true` this will cause RabbitMQ to use fully qualified names to identify nodes. This may prove useful in environments that use fully-qualified domain names or use IP addresses as hostnames or part of node names. Note that it is not possible to switch a node from short name to long name without resetting it.  **Default**: `false` |
| RABBITMQ\_SERVICENAME | The name of the installed Windows service. This will appear in `services.msc`.  **Default**: RabbitMQ. |
| RABBITMQ\_CONSOLE\_LOG | Set this variable to `new` or `reuse` to redirect console output from the server to a file named `%RABBITMQ_SERVICENAME%` in the default `RABBITMQ_BASE` directory.  - If not set, console output from the server will be discarded (default). - `new`: a new file will be created each time the service starts. - `reuse`: the file will be overwritten each time the service starts.  **Default**: (none) |
| RABBITMQ\_SERVER\_CODE\_PATH | Extra code path (a directory) to be specified when starting the runtime. Will be passed to the `erl` command when a node is started.  **Default**: (none) |
| RABBITMQ\_CTL\_ERL\_ARGS | Parameters for the `erl` command used when invoking `rabbitmqctl`. This could be set to specify a range of ports to use for Erlang distribution:   `-kernel inet_dist_listen_min 35672`   `-kernel inet_dist_listen_max 35680`  **Default**: (none) |
| RABBITMQ\_SERVER\_ERL\_ARGS | Standard parameters for the `erl` command used when invoking the RabbitMQ Server. This should be overridden for debugging purposes only.  **Default**:  - **UNIX**: `+P 1048576 +t 5000000 +stbt db +zdbbl 128000` - **Windows**: (none) |
| RABBITMQ\_SERVER\_ADDITIONAL\_ERL\_ARGS | Additional parameters for the `erl` command used when invoking the RabbitMQ Server. The value of this variable is appended to the default list of arguments (`RABBITMQ_SERVER_ERL_ARGS`).  **Default**:  - **Unix**: (none) - **Windows**: (none) |
| RABBITMQ\_SERVER\_START\_ARGS | Extra parameters for the `erl` command used when invoking the RabbitMQ Server. This will not override `RABBITMQ_SERVER_ERL_ARGS`.  **Default**: (none) |
| RABBITMQ\_DEFAULT\_USER | This environment variable is **only meant to be used in development and CI environments**. This has the same meaning as `default_user` in `rabbitmq.conf` but higher priority. This option may be more convenient in cases where providing a config file is impossible, and environment variables is the only way to [seed a user](https://www.rabbitmq.com/docs/access-control#seeding).  **Default**: (none) |
| RABBITMQ\_DEFAULT\_PASS | This environment variable is **only meant to be used in development and CI environments**. This has the same meaning as `default_pass` in `rabbitmq.conf` but higher priority. This option may be more convenient in cases where providing a config file is impossible, and environment variables is the only way to [seed a user](https://www.rabbitmq.com/docs/access-control#seeding).  **Default**: (none) |
| RABBITMQ\_DEFAULT\_VHOST | This environment variable is **only meant to be used in development and CI environments**. This has the same meaning as `default_vhost` in `rabbitmq.conf` but higher priority. This option may be more convenient in cases where providing a config file is impossible, and environment variables is the only way to [seed users](https://www.rabbitmq.com/docs/access-control#seeding) and virtual hosts.  **Default**: (none) |

Besides the variables listed above, there are several environment variables which tell RabbitMQ [where to locate its database, log files, plugins, configuration and so on](https://www.rabbitmq.com/docs/relocate).

Finally, some environment variables are operating system-specific.

| Name | Description |
| --- | --- |
| HOSTNAME | The name of the current machine.  **Default**:  - Unix, Linux: `env hostname` - MacOS: `env hostname -s` |
| COMPUTERNAME | The name of the current machine.  **Default**:  - Windows: `localhost` |
| ERLANG\_SERVICE\_MANAGER\_PATH | This path is the location of `erlsrv.exe`, the Erlang service wrapper script.  **Default**:  - Windows Service: `%ERLANG_HOME%\erts-<var>x.x.x</var>\bin` |

## Operating System Kernel Limits

Most operating systems enforce limits on kernel resources: virtual memory, stack size, open file handles and more. To Linux users these limits can be known as "ulimit limits".

RabbitMQ nodes are most commonly affected by the maximum [open file handle limit](https://www.rabbitmq.com/docs/networking#open-file-handle-limit). Default limit value on most Linux distributions is usually 1024, which is very low for a messaging broker (or generally, any data service). See [Deployment Guidelines](https://www.rabbitmq.com/docs/production-checklist) for recommended values.

### Modifying Limits

#### With systemd (Modern Linux Distributions)

On distributions that use systemd, the OS limits are controlled via a configuration file at `/etc/systemd/system/rabbitmq-server.service.d/limits.conf`. For example, to set the max open file handle limit (`nofile`) to `64000`:

```markdown
[Service]
LimitNOFILE=64000
```

See [systemd documentation](https://www.freedesktop.org/software/systemd/man/systemd.exec.html) to learn about the supported limits and other directives.

#### With Docker

To configure kernel limits for Docker containers, use the `"default-ulimits"` key in [Docker daemon configuration file](https://docs.docker.com/engine/reference/commandline/dockerd/#daemon-configuration-file). The file has to be installed on Docker hosts at `/etc/docker/daemon.json`:

```json
{
  "default-ulimits": {
    "nofile": {
      "Name": "nofile",
      "Hard": 64000,
      "Soft": 64000
    }
  }
}
```

#### Without systemd (Older Linux Distributions)

The most straightforward way to adjust the per-user limit for RabbitMQ on distributions that do not use systemd is to edit the `/etc/default/rabbitmq-server` (provided by the RabbitMQ Debian package) or [rabbitmq-env.conf](https://www.rabbitmq.com/docs/#config-file) to invoke `ulimit` before the service is started.

```markdown
ulimit -S -n 4096
```

This *soft* limit cannot go higher than the *hard* limit (which defaults to 4096 in many distributions).[The hard limit can be increased](https://github.com/basho/basho_docs/blob/master/content/riak/kv/2.2.3/using/performance/open-files-limit.md) via `/etc/security/limits.conf`. This also requires enabling the [pam\_limits.so](http://askubuntu.com/a/34559) module and re-login or reboot.

Note that limits cannot be changed for running OS processes.