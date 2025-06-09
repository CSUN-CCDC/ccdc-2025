{ pkgs ? import <nixpkgs> { }, pkgs-vagrant }:

let

  vagrant = pkgs.vagrant.overrideAttrs (oldAttrs: rec {
    doInstallCheck = false;
  });

  my-python-packages = ps: with ps; [
    ansible
    ansible-core
    molecule
    molecule-plugins
    dnspython
    jmespath
    pywinrm
    sqlalchemy
    mysqlclient
    psycopg2
    requests
    pyopenssl
    pymongo
    # other python packages
  ];
  #vagrantPackage = if builtins.pathExists /etc/wsl.conf then "" else "vagrant";
  vagrantDefaultProvider = if builtins.pathExists /etc/wsl.conf then "virtualbox" else "libvirt";

in
with pkgs;
mkShell {
  LC_ALL = "C.UTF-8";
  LANG = "C.UTF-8";
  ANSIBLE_HOST_KEY_CHECKING = "False";
  # PYTHONPATH = "${pkgs.python312.withPackages my-python-packages}/bin/python"; 
  VAGRANT_WSL_ENABLE_WINDOWS_ACCESS = "1";
  VAGRANT_DEFAULT_PROVIDER = "${vagrantDefaultProvider}";
  TEST_ENV = "${system}";
  buildInputs = [
    podman
    podman-compose
    # pkgs-vagrant.legacyPackages.${system}.vagrant
    vagrant
    openssh
    sshpass
    sshs
    (pkgs.python312.withPackages my-python-packages)
    ansible-lint
  ];
}
