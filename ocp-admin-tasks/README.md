# ocp-admin-tasks
This document has a list of Ansible playbooks and Shell scripts

Ansible playbooks provided here can be used to perform some usual admin activities in Openshift installations. 
Examples provided includes the following



*   [Create-openshift-objects](https://github.com/roshans416/ocp-admin-tasks/tree/master/create-openshift-objects)  - 

Used to create some default projects and groups from a list of names provided in a file. 
This name list should be defined under "files" folder. In this example, the names are populated in a file named "bu_list" . 
This playbook can be modified to repeat this task across multiple Openshift environments. 
Currently it assumes that there is only two environments, "prod" and "non-prod". 
But this can be extended to include any number of environments by changing the  "**ocenv**" variable defined in "**vars/envvars.yml**" file. 

*    [Modify-service-catalog](https://github.com/roshans416/ocp-admin-tasks/tree/master/modify-service-catalog) - 

Used to customize the Openshift service catalog. It will delete all the templates except what you would like to retain. 
Please provide the list of templates that should be retained in the "envvars.yml" file under "vars" directory. 

*   [Ldap-openshift-group-sync](https://github.com/roshans416/ocp-admin-tasks/tree/master/ldap-openshift-group-sync) - 

This playbook will deploy some scripts to Openshift master node and configure it to run as cron jobs. 
Scripts will automatically search for new sub groups in AD/LDAP which are members of a main Openshift group and sync that groups to Openshift. 
It will create new projects in Openshift based on the name of the groups. Groups will be given admin and view ro the projects in non-prod and prod clusters respectively.

A more detailed explanation of the various use cases can be found under each playbooks.
