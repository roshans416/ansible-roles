#!/bin/bash

#Querying LDAP to get the list of  groups under LSGRHO-openshift-group and saving the output to ldap_query_output file

ldapsearch -D "CN=SRVSGRHOCntrMgmt,OU=Users,OU=RHO,OU=SG,DC=PRU,DC=intranet,DC=asia" -y /root/.ldap/ldap.conf -h dsg001 -b DC=PRU,DC=intranet,DC=asia -o ldif-wrap=no -s sub "(cn=LSGRHO-openshift-group)" member | grep member: | awk {'print $2'}` > /root/.cron/ldap_query_output

#Creating/updating the whitelist file and cleaning up whitelist file (if already exists)

cat /root/.cron/ldap_query_output | grep member: | awk {'print $2'}` > /root/.cron/whitelist.txt


#Syncing the groups
oc adm groups sync --whitelist=/root/.cron/whitelist.txt --sync-config /root/.cron/augmented_ad_config_nested.yml --confirm
