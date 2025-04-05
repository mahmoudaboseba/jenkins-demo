output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.apache.public_ip
}


output "ssh_command" {
  value = "ssh -i ec2_key.pem ec2-user@${aws_instance.apache.public_ip}"
}
  
}

