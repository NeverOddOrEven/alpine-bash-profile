# An Alpine Image with Bash Runtime Configuration

There are times when I need to supply config to the container at runtime. I may need to set my proxy settings, or I might need to toggle some application flags, etc. I needed a base image that would bootstrap itself when passed known flags or options. This is easy enough to do with the Docker `ENTRYPOINT`, but I also wanted to freely switch between users in my container.   

This repository documents my efforts. I hope you find it useful to you.

## Building

You will need to install `git` if you haven't already. Then, execute the following commands on from your terminal. It should work on OS X, Linux, and MinGW.

```bash
git clone https://www.github.com/neveroddoreven/alpine-bash-profile.git alpine-bash-profile
cd alpine-bash-profile
docker build -t "neveroddoreven/alpine-bash-profile" .
```

## Users and Permissions

I like to run containerized apps with user-level privileges. Is it overkill? No idea. I see no reason to dismiss good security practices just because it is a container. 

This image is configured with two users: `root` and `appuser`. Both belong to the `appusers` group. Neither user requires a password, and either one may be used when starting a container.

## Running the Container

Running as `appuser` (the default user).

```bash
~ $ docker run -it --rm "neveroddoreven/alpine-bash-profile:latest"
~ $ docker run -it --rm -u appuser "neveroddoreven/alpine-bash-profile:latest"
```
<detail>
<summary>Output</summary>

```bash
Welcome appuser, from '/etc/bashrc'
Sourced by: /bin/bash.

This is not an interactive shell
This is not a login shell


Welcome appuser, from '/usr/share/entrypoint.sh'

This is not an interactive shell
This is not a login shell

appuser ~ $
```
</detail>

Running as root.

```bash
~ $ docker run -it --rm -u root "neveroddoreven/alpine-bash-profile:latest"
```
<detail>
<summary>Output</summary>

```bash
Welcome appuser, from '/etc/bashrc'
Sourced by: /bin/bash.

This is not an interactive shell
This is not a login shell


Welcome appuser, from '/usr/share/entrypoint.sh'

This is not an interactive shell
This is not a login shell

appuser ~ #
```
</detail>

Passing a known flag.

```bash
~ $ docker run -it --rm "neveroddoreven/alpine-bash-profile:latest" --some-var "some var"
```

<detail>
<summary>Output</summary>

```bash
Welcome appuser, from '/etc/bashrc'
Sourced by: /bin/bash.

This is not an interactive shell
This is not a login shell


Welcome appuser, from '/usr/share/entrypoint.sh'

This is not an interactive shell
This is not a login shell

Setting known flags
export SOME_VAR='some var'

appuser ~ $ echo $SOME_VAR
some var
```
</detail>

Passing an unknown flag/option.

```bash
~ $ docker run -it --rm "neveroddoreven/alpine-bash-profile:latest" -? "some var"
```

<detail>
<summary>Output</summary>

```bash
Welcome appuser, from '/etc/bashrc'
Sourced by: /bin/bash.

This is not an interactive shell
This is not a login shell


Welcome appuser, from '/usr/share/entrypoint.sh'

This is not an interactive shell
This is not a login shell

These unknown options were not processed
-?
some var
```
</detail>

Logged in as `appuser`, switching user to `root`.

```bash
appuser ~ $ sudo su - root
```

<detail>
<summary>Output</summary>

```bash
Welcome root, from '/etc/profile.d/welcome.sh'
Sourced by: -bash.

This is an interactive shell
This is a login shell
```
</detail>

Logged in as `root`, switching user to `appuser`.

```bash
root ~ $ su - appuser
```

<detail>
<summary>Output</summary>

```bash
Welcome appuser, from '/etc/profile.d/welcome.sh'
Sourced by: -bash.

This is an interactive shell
This is a login shell
```
</detail>

## License

This is published under the MIT open source license.
