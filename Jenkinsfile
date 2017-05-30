
pipeline {

    agent any 
    stages {
        stage('Initialize') {
            steps {
                echo 'Initialize Build'
                echo 'Copying over gradle scripts since git doesn\'t seem to work'
                sh 'cp -R $PIPELINE_HOME/* .'

            }

        }
        stage('Conflicts'){
            steps {
                echo 'Determine Conflicts'
                script {
                   try{
                    //will need to redirect std:out using something like this
                    //def out = sh script: './consoleOut.txt', returnStdout: true
                    sh './gradlew getConflicts -Pbranches=' + branchName
                    //Notify here if there are any conflicts
                    //placeholder value for parsed number
                    } catch (Exception ex) {
                        echo 'Failure during conflict detection: ' + ex.toString()
                        emailext subject: '$JOB_NAME $BUILD_NUMBER has failed',
                        body: 'Your build $JOB_NAME $BUILD_NUMBER has failed $BUILD_URL/console', 
                        to: notificationSendToID
                        throw ex
                    }
                }
            }
        }
        stage('PegaUnit Tests'){
            steps {
                echo 'Execute tests'
                //Notify here if the tests fail
                script {
                    try{
                   //sh './gradlew executePegaUnitTests -PaccessGroup=' + accessGroup
                   } catch (ex) {
                    echo 'Failure during testing: ' + ex.toString()
                    emailext subject: '$JOB_NAME $BUILD_NUMBER tests have failed',
                    body: 'Your build $JOB_NAME $BUILD_NUMBER has failing tests $BUILD_URL/console', 
                    to: notificationSendToID
                    throw ex
                }
            }
        }
    }
    stage('Merge'){
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
                 //         sh './gradlew getMergeStatus -Pbranches=' + branchName
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
    }
    stage('Continuous Integration') {
        steps {

            echo 'Starting CI..'
            sh  'pwd'
            sh './gradlew exportApplication'

            
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