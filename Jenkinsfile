pipeline {
    agent any;

    stages {
        stage('Check for merge conflicts'){
            steps {
                echo ('Clear workspace')
                deleteDir()
                withCredentials([
                    usernamePassword(credentialsId: 'imsadmin', 
                       passwordVariable: 'IMS_USER', 
                       usernameVariable: 'IMS_PASSWORD')
                    ]) {
                    echo 'Determine Conflicts'
                    script {
                     try{
                        sh "./gradlew getConflicts -PtargetURL=${PEGA_DEV} -Pbranch=${branchName} -PpegaUsername=imsadmin -PpegaPassword=devops"

                        } catch (Exception ex) {
                            echo 'Failure during conflict detection: ' + ex.toString()
                            mail (  to: notificationSendToID,
                                subject: "${JOB_NAME} ${BUILD_NUMBER} has failed",
                                body: 'Your build ' + env.JOB_NAME  +  env.BUILD_NUMBER + ' has failed ' + env.BUILD_URL + '/console', 
                                )
                            throw ex
                        }
                    }
                }
            }
        }
        stage('Run unit tests'){
            steps {
                echo 'Execute tests'

                withEnv(['TESTRESULTSFILE="TestResult.xml"']) {
                    withCredentials([
                        usernamePassword(credentialsId: 'imsadmin', 
                           passwordVariable: 'IMS_PASSWORD', 
                           usernameVariable: 'IMS_USER')
                        ]) {
                //Notify here if the tests fail
                script { 
                    try{
                        sh "./gradlew executePegaUnitTests -PtargetURL=${PEGA_DEV} -PpegaUsername=${IMS_USER} -PpegaPassword=${IMS_PASSWORD} -PtestResultLocation=${WORKSPACE} -PtestResultFile=${TESTRESULTSFILE}"

                        } catch (Exception ex) {
                            echo 'Failure during testing: ' + ex.toString()
                            mail (
                             subject: "${JOB_NAME} ${BUILD_NUMBER} tests have failed",
                             body: 'Your build ' + env.JOB_NAME  +  env.BUILD_NUMBER + ' has failing tests ' + env.BUILD_URL + '/console', 
                             to: notificationSendToID
                             )
                            throw ex
                        }
                    }
                    

                    junit "**/*.xml"
                    script {
                        if (currentBuild.result != null) {
                               mail (
                                subject: "${JOB_NAME} ${BUILD_NUMBER} tests have failed",
                                body: 'Your build ' + env.JOB_NAME  +  env.BUILD_NUMBER + ' has failing tests ' + env.BUILD_URL + '/console', 
                                to: notificationSendToID
                                 )
                               echo "Stopping pipeline due to failing tests"
                               input(input message: 'Ready to share tests have failed, would you like to abort the pipeline?')
                            }
                        }
                    }
                    

                }
            }
        }
    }
    stage('Merge branch'){

        steps{

            echo 'Perform Merge' 
            withCredentials([
                usernamePassword(credentialsId: 'imsadmin', 
                   passwordVariable: 'IMS_PASSWORD', 
                   usernameVariable: 'IMS_USER')
                ]) {
                script {
                    if ("true".equals(env.PERFORM_MERGE)) {;
                        try {
                            sh "./gradlew merge -PtargetURL=${env.PEGA_DEV} -Pbranch=${branchName} -PpegaUsername=${IMS_USER} -PpegaPassword=${IMS_PASSWORD}"
                            echo 'Evaluating merge Id from gradle script = ' + env.MERGE_ID
                            timeout(time: 5, unit: 'MINUTES') {
                                echo "Setting the timeout for 1 min.."
                                retry(10) {
                                    echo "Merge is still being performed. Retrying..."
                                    sh "./gradlew getMergeStatus -PtargetURL=${env.PEGA_DEV} --PpegaUsername=${IMS_USER} -PpegaPassword=${IMS_PASSWORD}"
                                    echo "Merge Status : " + env.MERGE_STATUS
                                }
                            }
                            }  catch(ex){
                             //Notify  if the merge fails
                             echo 'Failure during merging: ' + ex.toString()
                             mail (
                                subject: "${JOB_NAME} ${BUILD_NUMBER} merging branch " + branchName + " failed",
                                body: 'Your build ' + env.BUILD_NUMBER + ' has failed to merge due to: ' + ex.toString() + '\n\n' + env.BUILD_URL + '/console', 
                                to: notificationSendToID
                                )
     
                         }
                     }
                 }
             }
         }
     }

     stage('Export from Dev') {
        steps {
            echo 'Exporting application from Dev environment : ' + env.PEGA_DEV
            withCredentials([
                usernamePassword(credentialsId: 'imsadmin', 
                   passwordVariable: 'IMS_PASSWORD', 
                   usernameVariable: 'IMS_USER')
                ]) {
                sh "./gradlew performOperation -Dprpc.service.util.action=export -Dpega.rest.server.url=${env.PEGA_DEV}/PRRestService -Dpega.rest.username=${IMS_USER} -Dpega.rest.password=${IMS_PASSWORD}"
            }
        }
    }

    stage('Publish to Artifactory') {

        steps {

            echo 'Publishing to Artifactory '
            withCredentials([
               usernamePassword(credentialsId: 'artifactory', 
                  passwordVariable: 'ARTIFACTORY_PASSWORD', 
                  usernameVariable: 'ARTIFACTORY_USER')
               ]) {
                sh "./gradlew artifactoryPublish -PartifactoryUser=${ARTIFACTORY_USER} -PartifactoryPassword=${ARTIFACTORY_PASSWORD}"
            }
        }
    }

    stage('Regression Tests') {

        steps {
            echo 'Run regression tests'
            echo 'Publish to production repository'


        }
    }

    stage('Fetch from Artifactory') {

        steps {

            withCredentials([
                usernamePassword(credentialsId: 'artifactory', 
                    passwordVariable: 'ARTIFACTORY_PASSWORD', 
                    usernameVariable: 'ARTIFACTORY_USER'),
                usernamePassword(credentialsId: 'imsadmin', 
                    passwordVariable: 'IMS_PASSWORD', 
                    usernameVariable: 'IMS_USER')
                ]) {

                echo 'Fetching application archive from Artifactory'
                sh  "./gradlew fetchFromArtifactory -PartifactoryUser=${ARTIFACTORY_USER} -PartifactoryPassword=${ARTIFACTORY_PASSWORD}"
            }
        }
    }
    stage('Create restore point') {

        steps {
            withCredentials([
                usernamePassword(credentialsId: 'imsadmin', 
                   passwordVariable: 'IMS_PASSWORD', 
                   usernameVariable: 'IMS_USER')
                ]) {
                echo 'Creating restore point'
                sh "./gradlew createRestorePoint -PtargetURL=${PEGA_PROD} -PpegaUsername=${IMS_USER} -PpegaPassword=${IMS_PASSWORD}"
            }
        }
    }
    stage('Deploy to production') {
 
        steps {
            withCredentials([
                usernamePassword(credentialsId: 'imsadmin', 
                   passwordVariable: 'IMS_PASSWORD', 
                   usernameVariable: 'IMS_USER')
                ]) {

                echo 'Deploying to production : ' + env.PEGA_PROD
                sh "./gradlew performOperation -Dprpc.service.util.action=import -Dpega.rest.server.url=${env.PEGA_PROD}/PRRestService -Dpega.rest.username=${env.IMS_USER} -Dpega.rest.password=${env.IMS_PASSWORD}"
            }
        }
    }
}

}