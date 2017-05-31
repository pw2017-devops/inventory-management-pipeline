
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
                
            }
        }
        stage('Merge Branch'){
            steps{

                echo 'Perform Merge'
                
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