#!/bin/bash


#MArking the start of execution

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

# Checking whether the project already exist. If not, create one and granting admin role to group on the project.

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
