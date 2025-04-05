pipeline {
    tools {
  terraform 'terraform 1.11.0'
}

    parameters {
        booleanParam(name: 'autoApprove', defaultValue: false, description: 'Automatically run apply after generating plan?')
    } 
    environment {
        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
            }

   agent  any
    stages {
        stage('checkout') {
            steps {
                 script{
                        dir("terraform")
                        {
                            git "https://github.com/mahmoudaboseba/jenkins-demo.git"
                        }
                    }
                }
            }

        
       

        stage('Apply') {
            steps {
                sh "pwd;cd terraform/ ; terraform apply "
            }
        }
    }

  }
