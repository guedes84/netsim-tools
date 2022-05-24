# you can copy/paste and run all this text.
apt update && apt -y upgrade && apt -y autoremove
# THIS WILL REMOVE YOUR PYTHON3, Ansible and Asible core (to avoid troubles with others versions)
apt remove -y python3 ansible ansible-core 
apt install python3-pip
pip install --upgrade pip
pip install ansible ansible-core
cat > netsim-install.pb << EOF
---
- hosts: localhost
  gather_facts: no
  tasks:
    - name: "[ UPDATING SYSTEM PACKAGES ]"
      apt:
        update_cache: yes
        upgrade: full
        autoremove: yes
      register: aptout

    - name: "[ INSTALLING DEPENDENCIES OF NETLAB ]"
      apt:
        name: "{{ pkgs }}"
        state: present
      vars:
        pkgs:
          - python3-pip
          - vagrant-libvirt

    - name: "[ UPDATING PIP ]"
      shell:
        cmd: "pip install --upgrade pip"

    - name: "[ INSTALLING NETSIM-TOOL WITH PIP  ]"
      pip:
        name: "netsim-tools"

    - name: "[ INSTALLING NETLAB PACKAGES ]"
      shell:
        cmd: "netlab install -y ubuntu ansible libvirt containerlab"

    - name: "[ ADJUSTING TIME TO AVOID ISSUES ]"
      shell:
        cmd: "timedatectl set-timezone $(cat /etc/timezone) && timedatectl --adjust-system-clock"

    - name: "[ TESTING KVM LIBVIRT SUPPORT ]"
      shell:
        cmd: "kvm-ok"
      register: kvmout
      ignore_errors: True

    - debug:
        msg: "{{ kvmout }}"
EOF
ansible-playbook ./netsim-install.pb && netlab test libvirt
