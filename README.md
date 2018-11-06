[vagrant]: https://www.vagrantup.com/
[virtualbox]: https://www.virtualbox.org/

# ndex-vagrant

Creates virtual machine with ndex installed following 
instructions found here: http://www.home.ndexbio.org/installation-instructions/

## Requirements

* At least 8gb of ram, ideally 16gb

* [Vagrant][vagrant]

* [Virtual Box][virtualbox]

# To run

```Bash
git clone https://github.com/coleslaw481/ndex-vagrant.git
cd ndex-vagrant
vagrant up

# Visit http://localhost:8081 on browser
```

# To shutdown

From `ndex-vagrant` directory run the following command:

```Bash
vagrant destroy
```
