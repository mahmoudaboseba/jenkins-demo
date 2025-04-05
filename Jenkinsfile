pipeline {
    agent any
    tools {
  terraform 'terraform'
}

    environment {
        AWS_ACCESS_KEY_ID     = credentials('aws_access_key')
        AWS_SECRET_ACCESS_KEY = credentials('aws_secret_access_key')
        TF_KEY_FILE          = 'ec2_key.pem'
    }
    
    stages { 
        stage('Terraform Init/Apply') {
            steps {
                dir('terraform') {
                    sh 'terraform init'
                    sh 'terraform apply -auto-approve'
                    
                    // Save private key with secure permissions
                    sh 'terraform output -raw private_key > ../${TF_KEY_FILE}'
                    sh 'chmod 600 ../${TF_KEY_FILE}'
                    
                    // Capture EC2 IP
                    script {
                        env.EC2_IP = sh(script: 'terraform output -raw instance_public_ip', returnStdout: true).trim()
                    }
                }
            }
        }
        
        stage('SSH Configuration Test') {
            steps {
                script {
                    // Test SSH connection
                    sh """
                    ssh -i ${TF_KEY_FILE} \
                        -o StrictHostKeyChecking=no \
                        -o UserKnownHostsFile=/dev/null \
                        ec2-user@${env.EC2_IP} 'hostname'
                    """
                }
            }
        }
    }  
}
