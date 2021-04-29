# Java Ansible role

This Ansible Role installs java  [Oracle JDK](http://www.oracle.com/technetwork/java/javase/overview/index.html)) in a [Debian/Ubuntu or CentOS environment](https://github.com/idealista/java_role/blob/master/meta/main.yml#L7).


## Getting Started

To use this role as dependency in your playbook, prerequisites below:

Ansible 2.4.5.0 version installed.

### Contents

1) hosts  - Ansible inventory file. Please modify accordingly to add SSH key file, ansible username and host ip address.
2) roles/install-oraclejdk - Ansible role for installing Oracle JDK
3) main.yml  - Main ansible task file, which refers to "install-oraclejdk" role

### Role variables

**Default variables defined under "roles/install-oraclejdk/defaults/main.yml"**

1)java_oracle_jdk_version: 1.8.0_211

2)java_oracle_jdk_install_path: /opt/jdk/{{ java_oracle_jdk_version }}

"java_oracle_jdk_latest_versions_urls" : Defined under roles/vars/main.yml.

### How to execute this playbook?

```git clone https://github.com/roshans416/adecco```

```cd ansible```

```ansible-playbook -i hosts main.yml```


