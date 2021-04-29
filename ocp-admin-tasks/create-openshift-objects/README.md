# Use Case

Given the list of 28 BU's (Business Units), create an Ansible playbook to automate the provisioning of some default projects and groups, following the below mentioned criteria

For PROD



1.  One project per BU. Each project should have a default group with edit access.
1.  Name of the projects should follow the syntax "project-_buname_-prod", where "buname" is the name of respective BU's.
1.  Groups  should follow the syntax "group-_buname_-prod_" _, where "buname" is the name of respective BU's.

For NON-PROD



1.  3 projects per BU. Each project should have a default group with edit access.
1.  Name of the projects should follow the syntax "project-_buname_-sit" , "project-_buname_-uat" and "project-_buname_-dev". 
1.  Name of groups should follow the syntax "group-_buname_-sit" , "group-_buname_-uat" and "group-_buname_-dev".


## How to do this using shell script?

For this script to work properly, please find the prerequisites mentioned below.



1.  BU details should be added to a file. For eg: "**_bu_list_**"

  


```
          
          twlife          Demo Life Assurance Co. Ltd. Taiwan
          vnesiv          Demo Investments Fund Management Company
          vnlife          Demo Assurance Private Ltd
          vnpvfc          Demo Finance Co
```


            



1.  Also, pass a parameter to the script, prod or non-prod
1.  Script will fetch the BU details from the file and process accordingly.
1.  Should be logged as admin user to your Openshift cluster (Using OC)
1.  OC cli should be installed.
1.  Script should be executed as mentioned below

   

         # ./create_resources.sh prod                   # For production cluster

         # ./create_resources.sh  non-prod          # For non-prod cluster

 

          Where, **_create_resources.sh _**is the name of the script.

       

Please find below the script

          


```
 #!/bin/bash
RED="\033[1;31m"
GREEN="\033[0;32m"
NOCOLOR="\033[0m"

#Defining a help_function

help_function()
 {
#Checking whether any arguments has been passed.
if [ $# -eq 0 ]
   then
   echo -e "${RED}Please pass one parameter. Acceptable values are ${GREEN} prod ${NOCOLOR} and ${GREEN} non-prod ${NOCOLOR}"
   exit 1
fi
 }


# Check if executed as OCP system:admin
#if [[ "$(oc whoami)" != "system:admin" ]]; then
#  echo -n "Trying to log in as system:admin... "
#  oc login -u system:admin > /dev/null && echo "done."
#fi

case "$1" in

  prod)           echo "Production cluster"
                  #cluster= " " (Placeholder to define cluster information)
                  for i in `cat bu_list | awk {'print $1'}`
                  do
                    display_name=`cat bu_list | grep $i | cut -d' ' -f2-`
                    oc new-project project-$i-prod --display-name="$display_name"
                    oc adm groups new group-$i-prod
                    oc policy add-role-to-group view group-$i-prod -n project-$i-prod
                  done
  ;;
  non-prod)       echo "Non-Production cluster"
                  #cluster= " " (Placeholder to define cluster information)
                  for i in `cat bu_list | awk {'print $1'}`
                  do
                    display_name=`cat bu_list | grep $i | cut -d' ' -f2-`
                    oc new-project project-$i-sit --display-name="$display_name"
                    oc new-project project-$i-uat --display-name="$display_name"
                    oc new-project project-$i-dev --display-name="$display_name"
                    oc adm groups new group-$i-sit
                    oc adm groups new group-$i-uat
                    oc adm groups new group-$i-dev
                    oc policy add-role-to-group admin group-$i-sit -n project-$i-sit
                    oc policy add-role-to-group admin group-$i-uat -n project-$i-uat
                    oc policy add-role-to-group admin group-$i-prod -n project-$i-prod
                  done
  ;;
*)               help_function
  ;;

esac
```
## How to configure this using Ansible playbook?



1.  Following variables should be added to "envvar.yml" file under "vars" directory.

            


```
---
# Values of ocenv can either prod or non-prod
ocenv: 'non-prod'

# Suffix for non-prod project names
nonprod_list: ['sit', 'uat', 'dev']

# Name of Service Account user that should be created.
sa_user: 'ansible-user'

# Hostname or FQDN of Openshift master/endpoint
openshift_host: 'openshift-master'
```


2.  This playbook assumes that you are already logged into the Openshift cluster as admin or any similar user with cluster-admin role.

3. The playbook will create a service account initially with "ProjectRequest" and "GroupRequest" API access privileges and generates  a token for the same. This token will be used in Ansible "oc" module definitions for creating projects and groups.

4. This playbook while in execution will create some files, which will be saved under "files" directory.
