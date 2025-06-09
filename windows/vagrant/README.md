This directory consists of vagrant machines, defined by `Vagrantfile`'s, for testing Ansible playbooks or other variety testing.

Virtual machines are defined in `vagrant/folder/Vagrantfile`. With a folder your working directory, `vagrant status` shows you the machines you can bring up, as so:

```
(nix:nix-shell-env) [moonpie@cachyos-x8664 debian]$ vagrant status
Current machine states:

10                        not created (libvirt)
10_nospice                  not created (libvirt)

This environment represents multiple VMs. The VMs are all listed
above with their current state. For more information about a specific
VM, run `vagrant status NAME`.
```

Then, `vagrant up vmname` will create your machine. 

After a machine is up, there are several things you can do with it:  

`vagrant winrm vmname` will use winrm (think ssh but for by windows) to connect to a machine. You can also access these machines through the "virt-manager" graphical user interface.

And, an ansible inventory will be created at `.vagrant/provisioners/ansible/inventory/`. By referring to that folder path with `ansible-playbook -i .vagrant/provisioners/ansible/inventory`, you can run ansible playbooks against the created vagrant machines. 

`vagrant destroy -f` deletes machines.

Also, vagrant can snapshot machines depending on your setup.


`vagrant snapshot save vmname snapshotname` will save a snapshot. 

`vagrant snapshot restore vmname snapshotname` will restore a snapshot

`vagrant snapshot list` lists snapshots. 