
pipeline {
    agent any;

    stages {
        stage('Branch Merge Conflicts'){
            steps {
                echo 'Determine Conflicts'
                script {
                   try{
                    sh './gradlew getConflicts -PtargetURL=' + env.PEGA_DEV + '-Pbranch=' + branchName
                    
                    } catch (Exception ex) {
                        echo 'Failure during conflict detection: ' + ex.toString()
                        mail (  to: notificationSendToID,
                            subject: '$JOB_NAME $BUILD_NUMBER has failed',
                            body: 'Your build $JOB_NAME $BUILD_NUMBER has failed $BUILD_URL/console', 
                            )
                        throw ex
                    }
                }

            }
        }
        stage('Run unit tests'){
            steps {
                echo 'Execute tests'
                
                //Notify here if the tests fail
                script { 
                    try{
                        sh './gradlew executePegaUnitTests -PtargetURL=' + env.PEGA_DEV 

                        } catch (Exception ex) {
                            step([$class: 'JUnitResultArchiver', testResults: '**/target/surefire-reports/TEST-*.xml'])
                            if (currentBuild.result != null) {
                                echo 'Failure during testing: ' + ex.toString()
                                mail (
                                   subject: '$JOB_NAME $BUILD_NUMBER tests have failed',
                                   body: 'Your build $JOB_NAME $BUILD_NUMBER has failing tests $BUILD_URL/console', 
                                   to: notificationSendToID
                                   )
                                throw ex
                            }
                        }
                    }
                }
            }
            stage('Merge Branch'){
                steps{

                    echo 'Perform Merge'
                    script {
                        try {
                            sh './gradlew merge -PtargetURL=' + env.PEGA_DEV + '-Pbranches=' + branchName
                            echo 'Evaluating merge Id from gradle script = ' + env.MERGE_ID
                            timeout(time: 5, unit: 'MINUTES') {
                                echo "Setting the timeout for 1 min.."
                                retry(10) {
                                    echo "Merge is still being performed. Retrying..."
                                    sh './gradlew getMergeStatus -Pbranches=' + branchName
                                    echo "Merge Status : " + env.MERGE_STATUS
                                    //sleep(time: 30, unit: 'SECONDS')
                                }
                            }
                            }  catch(ex){
                        //Notify  if the merge fails
                        echo 'Failure during merging: ' + ex.toString()
                        mail (
                           subject: '$JOB_NAME $BUILD_NUMBER merge has failed',
                           body: 'Your build $BUILD_NUMBER has failed to merge due to: $ex $BUILD_URL/console', 
                           to: notificationSendToID
                           )
                        throw ex
                    }
                }
            }
        }
        
        stage('Publish to Artifactory') {
            steps {

                withEnv([APPLICATION_ARCHIVE_LOCATION= env.WORKSPACE ]) {

                    echo 'Exporting application from Dev environment : ' + env.PEGA_DEV
                    withCredentials([usernamePassword(credentialsId: 'IMS_PIPELINE_CREDENTIAL', passwordVariable: 'password', usernameVariable: 'username')]) {
                        sh './gradlew performOperation -Dprpc.service.util.action=export -Dpega.rest.server.url=$PEGA_DEV/PRRestService -Dpega.rest.username=$USERNAME -Dpega.rest.password=$PASSWORD'

                    }
                    sh './gradlew findArchive'

                    echo 'Publishing to Artifactory '
                    sh './gradlew artifactoryPublish'
                }
            }
        }

        stage('Continuous Delivery') {
           steps {
            echo 'Run regression tests'

        }
    }

    stage('Deployment') {
        steps {
            withEnv([APPLICATION_ARCHIVE_LOCATION= env.WORKSPACE]) {
             echo 'Deploying to production : ' + env.PEGA_PROD
             withCredentials([usernamePassword(credentialsId: 'IMS_PIPELINE_CREDENTIAL', passwordVariable: 'password', usernameVariable: 'username')]) {
               sh './gradlew findArchive'
               sh './gradlew performOperation -Dprpc.service.util.action=import -Dpega.rest.server.url=$PEGA_PROD/PRRestService -Dpega.rest.username=$USERNAME -Dpega.rest.password=$PASSWORD'                

           }
       }

   }
}

}
}