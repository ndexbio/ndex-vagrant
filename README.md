[vagrant]: https://www.vagrantup.com/
[virtualbox]: https://www.virtualbox.org/
[git]: https://git-scm.com/
[ndex]: https://ndexbio.org
 
# ndex-vagrant

Creates virtual machine with [NDEx][ndex] installed following 
instructions found here: 

http://www.home.ndexbio.org/installation-instructions/

## Requirements

* Mac or Linux box (should work on Windows, but have not tested)

* [Git] client

* At least 8gb of ram, ideally 16gb

* [Vagrant][vagrant]

* [Virtual Box][virtualbox]

## To run

Open a terminal and run the following commands:

```Bash
git clone https://github.com/ndexbio/ndex-vagrant.git
cd ndex-vagrant
vagrant up

# Visit http://localhost:8081 on browser
```

Once above is completed visit http://localhost:8081, via a webbrowser, on the same machine the above commands were invoked.

## To shutdown

From `ndex-vagrant` directory run the following command from a terminal:

```Bash
vagrant destroy
```
