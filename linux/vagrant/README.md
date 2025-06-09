This directory consists of vagrant machines, defined by `Vagrantfile`'s, for testing Ansible playbooks or other variety testing.

Virtual machines are defined in `vagrant/distroname/Vagrantfile`. With a distro name as your working directory, `vagrant status` shows you the machines you can bring up, as so:

```
(nix:nix-shell-env) [moonpie@cachyos-x8664 debian]$ vagrant status
Current machine states:

12                        not created (libvirt)
12docker                  not created (libvirt)

This environment represents multiple VMs. The VMs are all listed
above with their current state. For more information about a specific
VM, run `vagrant status NAME`.
```

Then, `vagrant up vmname` will create your machine. 

After a machine is up, there are several things you can do with it: 

`vagrant ssh vmname` will ssh into that machine.

And, an ansible inventory will be created at `.vagrant/provisioners/ansible/inventory/`. By referring to that folder path with `ansible-playbook -i .vagrant/provisioners/ansible/inventory`, you can run ansible playbooks against the created vagrant machines. 

`vagrant destroy -f` deletes machines.

Also, vagrant can snapshot machines depending on your setup.


`vagrant snapshot save vmname snapshotname` will save a snapshot. 

`vagrant snapshot restore vmname snapshotname` will restore a snapshot

`vagrant snapshot list` lists snapshots. 


To transfer files from the outside of the machine, into a vagrant machine over ssh:


`cat file | vagrant ssh vmname --  "cat > remotefile"`

