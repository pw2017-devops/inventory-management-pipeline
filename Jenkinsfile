pipeline {
    agent any;

    stages {
        stage('Branch Merge Conflicts'){
            steps {
                withCredentials([
                    usernamePassword(credentialsId: 'imsadmin', 
                       passwordVariable: 'password', 
                       usernameVariable: 'username')
                    ]) {
                    script {
                        def exportDirExists = fileExists env.WORKSPACE + '/build/export'
                        if (exportDirExists) {
                            dir(env.WORKSPACE + '/build/export') {
                                deleteDir()
                            }
                        }
                    }
                    echo 'Determine Conflicts'
                    script {
                     try{
                        sh './gradlew getConflicts -PtargetURL=' + env.PEGA_DEV + ' -Pbranch=' + branchName

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
                withCredentials([
                    usernamePassword(credentialsId: 'imsadmin', 
                       passwordVariable: 'password', 
                       usernameVariable: 'username')
                    ]) {
                //Notify here if the tests fail
                script { 
                    try{
                        sh "./gradlew executePegaUnitTests -PtargetURL=${PEGA_DEV} -PtestSuite=" + smokeTestSuite
                        
                        if (currentBuild.result != null) {
                        }
                        } catch (Exception ex) {
                            step([$class: 'JUnitResultArchiver', testResults: '**/target/surefire-reports/TEST-*.xml'])
                            if (currentBuild.result != null) {
                                echo 'Failure during testing: ' + ex.toString()
                                mail (
                                 subject: "${JOB_NAME} ${BUILD_NUMBER} tests have failed",
                                 body: 'Your build ' + env.JOB_NAME  +  env.BUILD_NUMBER + ' has failing tests ' + env.BUILD_URL + '/console', 
                                 to: notificationSendToID
                                 )
                                throw ex
                            }
                        }
                    }
                    junit '**/*.xml'
                }
            }

        }
        stage('Merge Branch'){
            steps{

                echo 'Perform Merge' 
                withCredentials([
                    usernamePassword(credentialsId: 'imsadmin', 
                       passwordVariable: 'password', 
                       usernameVariable: 'username')
                    ]) {
                    script {
                        if ("true".equals(env.PERFORM_MERGE)) {;
                            try {
                                sh './gradlew merge -PtargetURL=' + env.PEGA_DEV + ' -Pbranch=' + branchName
                                echo 'Evaluating merge Id from gradle script = ' + env.MERGE_ID
                                timeout(time: 5, unit: 'MINUTES') {
                                    echo "Setting the timeout for 1 min.."
                                    retry(10) {
                                        echo "Merge is still being performed. Retrying..."
                                        sh './gradlew getMergeStatus -PtargetURL=' + env.PEGA_DEV
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
                             throw ex
                         }
                     }
                 }
             }
         }
     }

     stage('Publish to Artifactory') {
        steps {
            echo 'Exporting application from Dev environment : ' + env.PEGA_DEV
            withCredentials([
                usernamePassword(credentialsId: 'imsadmin', 
                   passwordVariable: 'password', 
                   usernameVariable: 'username')
                ]) {
                sh "./gradlew performOperation -Dprpc.service.util.action=export -Dpega.rest.server.url=${env.PEGA_DEV}/PRRestService -Dpega.rest.username=${env.USERNAME} -Dpega.rest.password=${env.PASSWORD}"
            }


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

    stage('Continuous Delivery') {
     steps {
        echo 'Run regression tests'
        echo 'Publish to production repository'

    }
}

stage('Deployment') {
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

        echo 'Creating restore point'
        sh './gradlew createRestorePoint -PtargetURL=' + env.PEGA_PROD 

        echo 'Deploying to production : ' + env.PEGA_PROD
        sh "./gradlew performOperation -Dprpc.service.util.action=import -Dpega.rest.server.url=${env.PEGA_PROD}/PRRestService -Dpega.rest.username=${env.USERNAME} -Dpega.rest.password=${env.PASSWORD}"
    }
}
}
}

}