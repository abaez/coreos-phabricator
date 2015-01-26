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

### INSTALL
You need to first clone the repository from the git mirror or mercurial repo.

    hg clone https://a_baez@bitbucket.org/a_baez/coreos-phabricator
Afterwards, you will require build the docker container by running the
following inside the source:

    cd coreos-phabricator/
    docker build -t abaez/coreos-phabricator .

Lastly, add confd templates to confd setup mounted volume:

    cp coreos-phabricator/confd <confd volume location>

#### Fleet Setup
Copy the fleet services to your fleet instance directory like so:

    cp -R coreos-phabricator/fleet $HOME/fleet/instances/
After copying, you need to change `line 12` where the `/var/repo` and `/config`
location will be mounted on your setup.

Next, submit the fleet services from where you copied and edited:

    fleetctl submit $HOME/fleet/instances/*
Furthermore, load the the `db` services for the database. You can use your own
setup for this one if you already have a container you want to link to.
However, the suppliled `db` service setup has 90% chance to work.

    fleetctl load db*service
Finally, load the fleet services for phabricator with your choice of port. Due
keep in mind that the port for both the `phabricator-discovery` and
`phabricator` should be the same.
    fleetctl load phabricator@<your port> phabricator-discovery@<your port>

### USAGE
Again, due to the nature of the configuration, it is recommended to only use
confd for running the setup. You can however run phabricator from another tool.

Anyway, to run phabricator all you will have to do is start the `phabricator`
instance on fleet.

    fleetctl start phabricator@<your port>
The port will be the one you used for the load. The `start` command will run
all the other services of phabricator, including the `db` services. The same
for `stop` command on fleetctl.

    fleetctl stop phabricator@<your port>
Anyway, once your `phabricator` services are running, your confd setup should
initialize it with no problem and your good to go.
