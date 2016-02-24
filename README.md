# iRedMail-docker

The dockerisation is not yet complete. If you want to contribute and know how to, please do!
If you have questions regarding the method, or would like to suggest something, file an issue on this repo.

## Buildling

After cloing the repo, run `pre-build.sh` to get iRedMail and enable componentalization in its installation scripts.

Build takes the input from build-time environment variables, defined in docker-compose.

During the build, we imitate the 'mysql' and 'service' commands to capture their output
and execute it on first run of the container (TODO).

## How?

The pre-build script hooks the official installer so it can run in the build process, switching on or off specific parts of the installer. On top of that I'm caching the mysql queries executed during the installation so they can be applied once an instance is up.
It was quite a bit of work to get here, but now what's left is putting it all together - those small things like making sure the services talk to each other and not localhost, plus making a wrapper scripts that will boot up the necessary process.

## TODO

* `CMD` command that starts the each service once the container is ready
* Move the hardcoded passwords (in `util/config`) to variables in docker-compose.yml file
* Write a simple script that builds a **docker-compose override file** given a set of inputs (e.g. domain name)
* Make the services refer to each others by links/sockets, not `localhost` (possibly bind globally, not 127.0.0.1)
* Add LetsEncrypt for free, valid SSL certificates

## References and alternatives

* http://www.iredmail.org/docs/install.iredmail.on.debian.ubuntu.html
* http://www.iredmail.org/docs/file.locations.html
* http://www.iredmail.org/docs/network.ports.html
* https://github.com/adaline/dockermail
* https://github.com/cema-sp/iredmail-docker/