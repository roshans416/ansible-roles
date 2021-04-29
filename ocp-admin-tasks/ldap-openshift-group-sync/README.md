# Use Case



1.  Projects should be automatically created in OpenShift, whenever a new subgroup is created in AD under the main group "_LSGRHO-openshift-groups_"
2.  Naming convention of the subgroups should be as follows

**_G(COUNTRY)(BUSINESS UNIT)-(PROJECT NAME)-(OPTIONAL STRING)_**



3.  Groups should be automatically created in OpenShift from the corresponding AD sub-groups. Need a shell script that will be executed as a cron job in OpenShift master or from Bastion host with  oc "admin" access to OpenShift master.
4.  Projects should be created automatically. Name of the projects should be based on the strings in the sub-group.  Project name should use the following naming convention.

**_(2-CHAR COUNTRY)(BUSINESS UNIT CODE)-(PROJECT NAME)-(OPENSHIFT ENVIRONMENT)_**



5.  If the cluster is PROD, then the OpenShift groups should be granted read-only access in the respective projects.
6.  If the cluster is NON-PROD, then the Openshift groups should be granted "admin" access in the respective projects.
7.  Steps 4, 5 and 6 should be implemented in a shell script executed as a cron job at regular intervals.


##       How to deploy this scripts manually?



1.  Create a shell script (**_ldap-sync.sh_**) to get the sub-groups from the main group,  "**_LSGRHO-openshift-groups_**" . We will get the sub-groups and write the output to a file (whitelist.txt). 
2.  Then we will run the "**_oc adm groups sync_**" command against the "**_whitelist.txt_**" . Please find below the script.


```
 #!/bin/bash
  
#Querying LDAP to get the list of  groups under LSGRHO-openshift-group and saving the output to ldap_query_output file

ldapsearch -D "CN=SRVSGRHOCntrMgmt,OU=Users,OU=RHO,OU=SG,DC=PRU,DC=intranet,DC=asia" -y /root/.ldap/ldap.conf -h dsg001 -b DC=PRU,DC=intranet,DC=asia -o ldif-wrap=no -s sub "(cn=LSGRHO-openshift-group)" member | grep member: | awk {'print $2'}` > /root/.cron/ldap_query_output

#Creating/updating the whitelist file and cleaning up whitelist file (if already exists)

cat /root/.cron/ldap_query_output | grep member: | awk {'print $2'}` > /root/.cron/whitelist.txt


#Syncing the groups
oc adm groups sync --whitelist=/root/.cron/whitelist.txt --sync-config /root/.cron/augmented_ad_config_nested.yml --confirm
```




3.  Add the script to crontab for root . Please find below the example cron entry

        00 11 * * * root /bin/sh /root/.cron/ldap-sync.sh > /root/.cron/ldap-sync.log 2>&1
Where,  

**_ldap-sync.sh_** is the script doing the group sync.

**_/root/.cron/ldap-sync.log_** - We are redirecting both stdout and stderr from the script to  this log file.

**_Whitelist.txt_** - List of groups to be synced. Generated from the "ldapsearch" query output.

**_/root/.cron/augmented_ad_config_nested.yml_** -  Contains LDAP config details to connect to LDAP (AD) server

           



4.  Similarly, we need to add another script which performs the following.

*   Figure out whether the cluster is PROD or NON-PROD
*   Create project from group names.
*   Grant admin access to the groups on respective projects (if the cluster is NON-PROD)
*   Grant "view" (read-only) role to the groups on respective projects (If the cluster is PROD)
*   Please find below the script : **_group_to_project_map.sh_**

```
 #!/bin/bash
  

#Marking the start of execution in the log file. 
echo "RUNNING $0 AT `date +%x_%r`"
echo "================================="

#Checking whether the cluster is DEV or PROD. This assumes that you have PROD or DEV substring in your Openshift server URL.

/bin/oc whoami --show-server | grep -i dev >& /dev/null

if [ $? == 0 ]; then

#If the cluster is DEV

  for i in `cat /root/.cron/whitelist.txt | grep -v GSGRHO-openshift_admins`
  do
    display_name=`echo $i | cut -c 5- | cut -d',' -f1`
    group_name=`echo $i | cut -c 4- | cut -d',' -f1`
    project_name=`echo $i | cut -c 5- | cut -d',' -f1 | awk '{print tolower($0)}'`-dev

# Checking whether the project already exist. If not, create one and granting admin role to group on the project.

      /bin/oc get projects | grep $project_name >& /dev/null
      if [ $? != 0 ]; then
         echo "Creating project $project_name"
         /bin/oc new-project $project_name --display-name="$display_name"
         /bin/oc policy add-role-to-group admin $group_name -n $project_name
      fi
  done

else

#If the cluster is PROD

for i in `cat /root/.cron/whitelist.txt | grep -v GSGRHO-openshift_admins`
  do
    display_name=`echo $i | cut -c 5- | cut -d',' -f1`
    group_name=`echo $i | cut -c 4- | cut -d',' -f1`
    project_name=`echo $i | cut -c 5- | cut -d',' -f1 | awk '{print tolower($0)}'`-prod

# Checking whether the project already exist. If not, create one and granting view role to group on the project.

      /bin/oc get projects | grep $project_name >& /dev/null
      if [ $? != 0 ]; then
         echo "Creating project $project_name"
         /bin/oc new-project $project_name --display-name="$display_name"
         /bin/oc policy add-role-to-group view $group_name -n $project_name
      fi
  done
fi
echo "FINISHED $0 AT `date +%x_%r`"
echo "=============================="
```
