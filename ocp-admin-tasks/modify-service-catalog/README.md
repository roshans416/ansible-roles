# Use Case

Customize the Openshift Service Catalog to display only the templates required by the team and delete all the unnecessary templates loaded by default during the OCP cluster installation. Automate this using an Ansible playbook. 


## Technology BreakDown:


### Service Catalog:

The service catalog allows cluster administrators to integrate multiple platforms using a single API specification. The OpenShift Container Platform web console displays the service classes offered by brokers in the service catalog, allowing users to discover and instantiate those services for use with their applications.



1.   Templates are loaded to "Openshift" project by default. Template Service Broker (TSB) registered with  Service Catalog is configured to check the "Openshift" project by default for the loaded templates. 
1.  For each templates loaded into Openshift project, TSB will create a "ClusterServiceClass" resource. A Service Class is a type of managed service offered by a particular broker.
1.  End users can consume this from the service catalog, thereby creating a service instance of the service class.


## How to customize the service catalog manually?

We have to delete all the Cluster Service Classes (CSC) apart from what we should retain.



1.  Get the list of "ClusterServiceClass"

        oc get clusterserviceclass

ClusterServiceClass will be in the following format .

      Bb6092c8-3300-11e8-9602-080027594559


  2.   Figure out which service class to be deleted. For that, execute the following command to generate a mapping of ClusterServiceClass ID and externalName (name of the template  where CSC is referring to)

           oc get clusterserviceclasses -o=custom-columns=ID:.spec.externalID,NAME:.spec.externalName | grep -v NAME

This will give an output as follows.

```
ID                                                                         NAME                                                                 

bb5c14b7-3300-11e8-9602-080027594559   mariadb-persistent
bb5ea480-3300-11e8-9602-080027594559   mongodb-ephemeral
bb5f95a0-3300-11e8-9602-080027594559   mongodb-persistent
bb6092c8-3300-11e8-9602-080027594559   mysql-ephemeral
bb617bc7-3300-11e8-9602-080027594559   mysql-persistent
```


Now, we can easily figure out which Service Class needs to deleted.

3.  Delete the service classes not needed using the following command, for eg:

        oc delete clusterserviceclass/bb5c14b7-3300-11e8-9602-080027594559

Replace the Cluster Service ID with the one which you want to delete.


## How to customize the service catalog using Ansible?



1.  This can be executed in different environments. Please modify the "**ocenv"** variable in "**envvars.yml**" file under "vars" directory.
2.  Name of templates to be retained should be given as a variable list. Please modify 
'**csc_ext_name_list**"  in "**envvars.yml**" file under "vars" directory. Please find below example   


```
---
ocenv: 'non-prod'
csc_ext_name_list: ['mysql-ephemeral', 'jenkins-ephemeral', 'mariadb-ephemeral']
openshift_host: 'openshift-master'
```


 

 3. Once the playbook is executed, all the templates except wat mentioned in    **csc_ext_name_list** will be removed from Service Catalog.

 4. "**openshift_host**" variable should be set to the FQDN or hostname of OpenShift Master.

 5. Playbook creates some files while executing. These files be created under "**files**" directory in the playbook.
