
pipeline {
    agent any;

    stages {
        stage('Branch Merge Conflicts'){
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
    
    }
}