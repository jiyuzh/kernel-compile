# Compile HOWTO

### Config Script

1. Run [configure.sh](configure.sh): `./configure.sh {localver_name} [{config_type}] {ext_args}`
   
   :twisted_rightwards_arrows: You may override `lsmod` result with a `lsmod.override` file
   
   :clipboard: See in-script help for usage

2. Enable experiment-delicated kernel configs

3. Do other config edits

4. `ln .config config.example`
   
   :twisted_rightwards_arrows: You may skip this step
   
   :clipboard: This command creates a hard link, allowing git to track current configs through `config.example`
   
   :warning: The committed config is for reference only, since module requirements may differ

5. Use build script to compile

### Build Script

1. Run [build.sh](build.sh): `./build.sh`

### Distrubited Build Script

1. Run [distbuild.sh](distbuild.sh): `./distbuild.sh`

### Kernel Installation Script

1. Run [install.sh](install.sh): `sudo ./install.sh`

2. Reboot

### Kernel Uninstall Script

1. Run [uninstall.sh](uninstall.sh): `sudo ./uninstall.sh {kernel_version}`

### Validator Script

Run [validate.sh](validate.sh): `./validate.sh {ext_args}`


### Manual Configuration Steps

1. Download [standard config](https://github.com/nyrahul/linux-kernel-configs/blob/main/Ubuntu%2020.04.3%20LTS/5.11.0-1022-aws/bootconfig.md) ([local copy](ubuntu-20.04.config))

2. `make listnewconfig | tee .config.newdiff`
   
   :clipboard: List and track newly added configs and their default value

3. `make olddefconfig`
   
   :twisted_rightwards_arrows: Or `make oldconfig` to tweak each config manually
   
   :clipboard: Apply default values to newly added configs

4. `make localmodconfig`
   
   :clipboard: Remove uncessary modules
   
   :warning: Make sure all necessary system functionalities are used at least once before, or [prepare a LSMOD file](https://docs.kernel.org/admin-guide/README.html#configuring-the-kernel)

5. `echo '+' > .scmversion`
   
   :clipboard: Force append `+` to version number, i.e. `5.18.0+`
   
   :warning: Will also nullify `CONFIG_LOCALVERSION_AUTO`

6. `make menuconfig`
   
   :twisted_rightwards_arrows: Or `make xconfig` for graphic interface
   
   1. `CONFIG_SYSTEM_TRUSTED_KEYS=""`
      
      `CONFIG_SYSTEM_REVOCATION_KEYS=""`
      
      :clipboard: Remove cert requirment
   
   2. `CONFIG_SECURITY_DMESG_RESTRICT=n`
      
      :clipboard: Allow non-sudo `dmesg`
   
   3. `CONFIG_LOCALVERSION="<VALUE>"` 
      
      :clipboard: Add kernel version suffix, e.g. `-custom`
   
   4. Adapt config for special software
      
      :clipboard: [`libvirt`](https://gitweb.gentoo.org/repo/gentoo.git/tree/app-emulation/libvirt/libvirt-8.4.0.ebuild#n144) and [`docker`](https://github.com/moby/moby/blob/master/contrib/check-config.sh) requirements
   
   5. Enable experiment-delicated kernel configs
   
   6. Do other config edits

7. `ln .config config.example`
   
   :twisted_rightwards_arrows: You may skip this step
   
   :clipboard: This command creates a hard link, allowing git to track current configs through `config.example`
   
   :warning: The committed config is for reference only, since module requirements may differ

8. Use build script to compile

### Prepare LSMOD

```bash
# Also, you can preserve modules in certain folders
# or kconfig files by specifying their paths in
# parameter LMC_KEEP.

target$ lsmod > /tmp/mylsmod
target$ scp /tmp/mylsmod host:/tmp

host$ make LSMOD=/tmp/mylsmod \
           LMC_KEEP="drivers/usb:drivers/gpu:fs" \
           localmodconfig
```

# Script Manual

### configure.sh

The script will try to build a linux kernel configure file in current working directory.

It will only work when invoked at the root directory of a valid linux source tree.

The script will generate new config file at `$PWD/.config`

```
./configure.sh {localver_name} [{config_type}] {ext_args}
Automatic kernel configuration generator for Linux 5.x
    localver_name: Value provided to CONFIG_LOCALVERSION, without leading dash
    config_type: The fullness of the config, the default value is 'lite'
        full: Do not remove unused modules
        lite: Remove modules that are not loaded
    ext_args: A series of arguments tweaking the extension options
              The default is to use all available extensions
```

This script will invoke ***extensions***. See details below.

This script will also look for these files in `$SCRIPT_DIR`:

- `ubuntu-20.04-5.4.config`: The base config file. The script will derive new config files from this file.

This script will also look for these files in `$PWD`:

- `lsmod.override`: The `lsmod` override file. If this file exists, the script will source this file (instead of running `lsmod` command) when invoking `make localmodconfig`.

- `local-configure.sh`: Local config modification script. If this file exists, the script will invoke it to modify the generated kernel config. This file will be invoked after all automated modification extensions.

- `.config`: Generated config file. The script will write the result into this file. If this file already exists, the script will backup it first.

- `.config.newdef`: Derived new definitions record file. If any config item is not described in the base config file, it's name and default value will be written to this file.

### distcompile.sh

To use this script, you must have `distcc` installed on both client and server first.

It is strongly recommended to compile `distcc` from source. Here is a sample script to do this:

```bash
sudo apt install -y gcc make python3 python3-dev libiberty-dev autoconf checkinstall

wget https://github.com/distcc/distcc/releases/download/v3.4/distcc-3.4.tar.gz
tar xf distcc-3.4.tar.gz
cd distcc-3.4

./autogen.sh
./configure
make

sudo checkinstall
make installcheck
sudo update-distcc-symlinks
```

After that, please configure `distcc` host in `~/.ssh/config` and `~/.distcc/hosts`.

Please order the hosts in `~/.distcc/hosts` from fastest to slowest. The syntax is `@<ssh_host>/<parallel_allowance>`.

Here are some examples:

```
# ~/.ssh/config

Host distcc.server1
    HostName 192.168.0.2
    User distcc
    IdentityFile ~/.ssh/id_rsa
```

```
# ~/.distcc/hosts

localhost/12
@distcc.server1/36
```

### validate.sh

This script will validate current kernel config with a series of validator.

```
./validate.sh [nofail] {ext_args}
Automatic kernel configuration validator for Linux 5.x
    nofail: Indicate that the script shall not return with error code
    ext_args: A series of arguments tweaking the extension options
              The default is to use all available extensions
```

This script will validate the first config file encountered in this list:

```bash
$PWD/.config
/proc/config.gz
/boot/config-$(uname -r)
/usr/src/linux-$(uname -r)/.config
/usr/src/linux/.config
```

This script will invoke ***extensions***. See details below.

This script will also look for these files in `$PWD`:

- `local-validate.sh`: Local config validation script. If this file exists, the script will invoke it to validate the kernel config.

### Extension arguments (`ext_args`)

The extension argument list is a list of rules on which extension to enable/disable.

The argument list is always interperted from left to right. When conflicts observed, the rightmost option shall prevail.

The extension manager will ignore any unrecognized arguments and extension names.

Extension names are case sensitive.

The default behavior is to include all extensions, except those which declared `# ext-default-enabled: no` in their extension script.

Available arguments:

```
--no-all: Disable all extensions
--with-all: Enable all extensions
--no-{ext_name}: Disable the extension named {ext_name}
--with-{ext_name}: Enable the extension named {ext_name}
```

Example:

```
#   Enable all default extensions except libvirt
--no-libvirt

# Overwrite rule
#   Enable all extensions except docker and hyperv
--with-all --no-docker --no-hyperv

#   Enable docker only
--no-all --with-docker

#   Enable libvirt only
--with-docker --with-hyperv --no-all --with-libvirt
```

### Extensions

The scripts are extensible through different extensions.

Extensions shall be placed in `./extension/` of the script folders, with specific naming convention.

The name shall be `{ext_name}-{invoker_name}.sh`. For example, a `docker` extension to be invoked by `validate.sh` shall named `docker-validate.sh`.

Extension names are case sensitive.

Reserved `ext_name`s:

```
These values are reserved and shall not be ext_name:
    <empty>, all, base, local
```

##### configure.sh

`enable_flags {flag_list}`: Enable a list of flags

`module_flags {flag_list}`: Make module a list of flags

`disable_flags {flag_list}`: Disable a list of flags

`set_flag_str {flag} {value}`: Set flag value to a double-quoted string

`set_flag_num {flag} {value}`: Set flag value to a number

##### validate.sh

This script provides the following special global variables and functions:

`check_flags {flag_list}`: Require a list of flags to be enabled (or as module) in the **checking** kernel.

`check_yes_flags {flag_list}`: Require a list of flags to be enabled (and not as module) in the **checking** kernel.

`check_no_flags {flag_list}`: Require a list of flags to be not enabled in the **checking** kernel.

`check_arch {arch}`: Require the architecture of the **running** environment.

`check_command {command}`: Require a command to present in the **running** environment.

`check_device {path}`: Require a device to present in the **running** environment.

`$kernelMajor`: Major version of current **running** kernel.

`$kernelMinor`: Minor version of current **running** kernel.

`$EXITCODE`: The return code of current validator. A non-zero value indicates error. All `check_*` provided by this script will set `$EXITCODE` to `1` upon failure.
