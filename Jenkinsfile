pipeline {
    tools {
  terraform 'terraform 1.11.0'
}

    parameters {
        booleanParam(name: 'autoApprove', defaultValue: false, description: 'Automatically run apply after generating plan?')
    } 
    environment {
         AWS_CREDENTIALS = 'aws-credentials-id'
      // AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
        //AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        TERRAFORM_DIR = 'terraform'
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

     stage('Run Terraform') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: AWS_CREDENTIALS, accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
                    dir(TERRAFORM_DIR) {
                        sh '''
                            export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
                            export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
                            terraform init
                           # terraform destroy -auto-approve
                            terraform apply -auto-approve
                
                        '''
                    }
                }
            }
        }

         stage('Run Ansible') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: AWS_CREDENTIALS, accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
                    dir(ANSIBLE_DIR) {
                        sh '''
                          //  cat inventory
                            ansible-playbook -i inventory install_httpd.yml
                        '''
                    }
                }
            }
        }
    }
    }
}

  
