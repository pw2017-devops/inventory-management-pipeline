
pipeline {
    agent any;

    stages {
        stage('Branch Merge Conflicts'){
            steps {
                echo 'Determine Conflicts'
                script {

                }
            }
        }
        stage('PegaUnit Tests'){
            steps {
                echo 'Execute tests'
                build 'ExecutePegaUnitTests'
                //Notify here if the tests fail
                script {
                    if (currentBuild.result != null) {
                        echo 'Failure during testing: ' + ex.toString()
                        emailext subject: '$JOB_NAME $BUILD_NUMBER tests have failed',
                        body: 'Your build $JOB_NAME $BUILD_NUMBER has failing tests $BUILD_URL/console', 
                        to: notificationSendToID
                        throw ex
                    }
                }
            }
        }
        stage('Merge Branch'){
            steps{

                echo 'Perform Merge'
                script {
                    try{
                    // sh './gradlew merge -Pbranches=' + branchName
                    // echo 'Evaluating merge Id from gradle script = ' + env.MERGE_ID
                    // timeout(time: 5, unit: 'MINUTES') {
                    //     echo "Setting the timeout for 1 min.."
                    //     retry(10) {
                    //         echo "Merge is still being performed. Retrying..."
                    sh './gradlew getMergeStatus -Pbranches=' + branchName
                    //         echo "Merge Status : " + env.MERGE_STATUS
                    //         sleep(time: 30, unit: 'SECONDS')
                    //     }
                    // }
                    }  catch(ex){
                    //Notify here if the merge fails
                    echo 'Failure during merging: ' + ex.toString()
                    emailext subject: '$JOB_NAME $BUILD_NUMBER merge has failed',
                    body: 'Your build $BUILD_NUMBER has failed to merge due to: $ex $BUILD_URL/console', 
                    to: notificationSendToID
                    throw ex
                }
            }
        }
        stage('Continuous Integration') {
            steps {

                sh 'echo Exporting application from Dev environment $DEV_ENV'
                sh './gradlew performOperation -Dprpc.service.util.action=export -Dpega.rest.server.url=$DEV_ENV/PRRestService -Dpega.rest.username=$PIPELINE_USER -Dpega.rest.password=$PIPELINE_USER_PASSWORD -Dexport.archiveName=$APPLICATION_NAME_$APPLICATION_VERSION.zip -Dexport.applicationName=$APPLICATION_NAME -Dexport.applicationVersion=$APPLICATION_VERSION -Dexport.async=false -Dservice.responseartifacts.dir=$WORKSPACE/export"'                
                sh 'ls -lh $WORKSPACE/export'


            }

        }
        stage('Continuous Delivery') {
            steps {
                echo 'Testing..'
            }
        }
        stage('Deployment') {
            steps {
                echo 'Deploying....'
            }
        }
    }
}