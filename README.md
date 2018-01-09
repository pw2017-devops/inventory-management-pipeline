# Example release pipeline for a Pega 7.3.1 application 

<a href="https://www.pega.com">
<img src="https://www.pega.com/profiles/pegasystems/themes/custom/pegas/pegakit/public/images/logos/pega-logo.svg" width="200" alt="Pegasystems"/>
</a>

This is an example implementation of a continuous delivery pipeline for a Pega application. This pipeline has the following workflow 
- *Continuous Integration* by rules develoeprs by triggering a build pipeline on on merge of a rules branch. This will trigger the execution of PegaUnit test, specifically a smoke test suite, which if it passes, will merge the branch that triggered the build. After successful merge, the application, Inventory Management System, will be exported from the Dev system and published to a binary repository located in Artifactory.
- *Continuous Delivery* - this is the section of the pipeline where the application archive stored in the repository from the earlier CI process is imported into a test environment for further regression and acceptance testing. In this example pipeline, this is represented by the "Regression Tests" stage.
- *Continuous Deployment* - Here the pipeline will create a restore point in the application on the production environment prior to importing the application archive from the Artifactory repository. The production environment is expected to be configured with the appropriate production level settings.

# Notes 

This is meant to be a example implementation to showcase how a continuous delivery or continuous deployment pipeline can be achieved using the out of the box APIs in the Pega 7 platform, in this example Pega 7.3.1 . As such there are a few shortcuts that have been taken such as
- Only two environments are assumed, Dev and Prod, whereas a pipeline for a real application is likely to have multiple additional stages and environments. As such the Regression Tests stage is an empty stage that does not does not do anything. Similarly there is likely to be a Pre-prod or staging environment prior to deploying to a production environment
- Only one binary repository is assumed, however it is likely that there is more than one repository, such as a development repository that stores the inital build (exported application archive) while it is being validated and then a production respository where the final validated build is stored and is considered the source for the production environments
- This pipeline assumes that a *branchName* and a *notificationSendToID* has been specified as build parameters, see the section below around Jenkins configuration for more details
- The pipeline assumes that all environments invovled are configured to be https, which includes Jenkins, Artifactory and Pega

**This is just a starting point for your CI/CD pipelines and is meant to get you to start exploring how to enable such pipelines with Pega, the supplied ode is provided without any support. However this should be an excellent starting point to enable your teams to build a simple pipeline and grow in complexity over time**

# Prerequisites
- Jenkins: https://jenkins.io/download/
- Artifactory: https://www.jfrog.com/open-source/
- Pega 7.3 - this release is now GA and should be available. Please contact your appropriate Pega representative for further details or you can request personal edition that should be available to you as part of the Pega Developer Network
- InventoryManagementSystem example application archive - https://pega.box.com/s/8eryj1qijd49dd6moi5dgtvf7xgm21cc

# Jenkins configuration
In order for this pipeline to work in Jenkins, you need to configure a job in Jenkins that pulls this pipeline configuration defined in the Jenkinsfile. In order to do this, you need to the following plugins in Jenkins
- **Pipeline** plugin  (allows the definition of a CI/CD pipeline in Jenkins)
- **Blue Ocean** (pipeline visualizer)
- **Credentials** plugin  (to support passing in authenticaion credentials for https systems)
- **Build Authorization Token Root** plugin (to allow remote triggering of Jeknins jobs)
- **Git** plugin (in order to support pulling the code directly from the Git repository)

Make sure to install all the associated plugins suggested when installing the above plugins to ensure that all the functionality is available. There is plenty of information on the web on how to install and configure these plugins.

This particular Jenkinsfile assumes that there area few global environment variables available, therefore make sure that the following environment variables are available under *Manage Jenkins --> Configure system* 
- **ARTIFACTORY_URL**:  url to the artifactory installation 
- **PEGA_DEV**: url to the Pega 7.3 installation for the dev environment
- **PEGA_PROD**: url to the Pega 7.3 installation for the production environment
- **PERFORM_MERGE**: true/false value   indicating whether Jenkins should do the actual rules branch merge or not (useful for debugging or simply when testing the pipeline)

As mentioned earlier, the pipeline code assumes that all systems require authentication and as such there are two that is looks for
- **artficatory**: artifactory credentials
- **imsadmin**: administrative operator credentials used by the pipeline REST invocations that have the appropriate priveleges to execute the serves as well as allow for deployments and schema management on production level 5 environments. For the example application provided in the PegaWorld bootcamp, the username/password is *imsadmin/devops*
These credentails can be added through *Configure credentials* and ensure that it is available to the project you are going to create below. If you are having issues, ensure that these are global in scope.

Once all of the above have been configured, you need to now create a new Jenkins project. Your goal is to create a new *Pipeline* project, which should be available if you have installed the Pipeline plugin from before. Once you have named and created a new Jenkins project
- Select *This project is parameterized* and add the following paramters
-- **branchName** (String parameter) : name of the rules branch that will be supplied by Pega when invoking the build
-- **notificationSendToID** (String parameter) : email address of the user that kicked off the build to notify on event of build failure
- Select *.Do not allow concurrent builds* if you want to avoid having mutlitple builds be active simultaneously especially when dealing with static environments, for example you do not want to have multiple deployments happening simultaneously to a production 
- Select "Trigger builds remotely (e.g. from scripts)" and fill in the following Authentication Token "IMSStartBuild". This token is what is used to trigger the build remotely from Pega
- Under the *Pipeline* section, select *Pipeline script from SCM* from the dropdown for Definition, chose *Git* for the SCM and provide this Git repository URL - https://github.com/pw2017-devops/inventory-management-pipeline.git (since this is a Github location, additional authentication is not needed). Leave everything else as default but do ensure that the *Script Path* is set to Jenkinsfile without any other path location in front of it.

This should now be a fully configured Jenkins project ready to execute a build for the InventoryManagementPipeline application provided as part of the PegaWorld bootcamp.


# Artifactory configuration
Once you have installed and configured Artifactory, the setup is pretty straightforward, all that is required is a repository that is named **ims_devel_repo**. This pipeline assumes a Maven style repository which should be an option for a standard Artifactory installation. Feel free to experiement with other types of repositories.

 





