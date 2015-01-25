# coreos-phabricator
A coreos docker container for phabricator with only mercurial configuration by
[Alejandro Baez](https://twitter.com/a_baez)

---

### DESCRIPTION
This is a docker container built with the idea of being used inside [coreos](https://coreos.com/).
It has all the [fleet](https://github.com/coreos/fleet) configuration files and
[confd](http://www.confd.io/) setup ready for use. Do note that the docker
container only builds for use with mercurial version control hosting and not
git or any other preference.

Since the container was built with use on coreos in mind, it may not work or
need adjustment to use on docker directly.

### DEPENDENCIES

*   [confd](http://www.confd.io/) configured with [nginx](http://nginx.org/)
*   [coreos](https://coreos.com/)
*   Mercurial or the git mirror on github.
