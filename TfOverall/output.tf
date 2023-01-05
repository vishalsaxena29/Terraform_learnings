output "myoutput" {
  value = aws_instance.My-Ubuntu-Instance.availability_zone
}

output "myoutput2" {
  value = aws_instance.My-Ubuntu-Instance.public_ip
}