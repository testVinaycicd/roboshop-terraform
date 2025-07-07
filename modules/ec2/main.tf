variable "root_volume_size" {
    default = ""
}
resource "aws_instance" "instance" {

    ami = var.ami_id # Amazon Linux 2 AMI in us-east-1
    instance_type = var.instance_type
    vpc_security_group_ids = var.vpc_security_group_ids
    root_block_device {
        volume_size = var.root_volume_size
        volume_type = "gp2"
    }
    tags = {
      Name = " ${ var.name }-terraform "
    }
}

resource "aws_route53_record" "frontend" {

    zone_id = var.zone_id
    name    = "${var.name}-${var.env}"
    type    = "A"
    ttl     = 10
    records = [aws_instance.instance.public_ip]
}

# resource "aws_route53_record" "public" {
#
#     zone_id = var.zone_id
#     name    = "${var.name}-${var.env}"
#     type    = "A"
#     ttl     = 10
#     records = [aws_instance.instance.public_ip]
# }

#
#
# #everytime if provisioner change the whole instance is recreated so better keep it outside aws instance in a null_resource
resource "null_resource" "frontend" {
    depends_on = [aws_route53_record.frontend]

    triggers = {
        instance_id_change = aws_instance.instance.id
    }

    provisioner "remote-exec" {

        connection {
            type     = "ssh"
            user     = "ec2-user"
            password = "DevOps321"
            host     = aws_instance.instance.private_ip
        }


        inline = [
            "sudo pip3.11 install ansible hvac",
            "until nslookup ${var.name}-dev.mikeydevops1.online; do echo 'Waiting for DNS...'; sleep 5; done",
            "ansible-pull -i localhost, -U https://github.com/VinayBKrishna/roboshop-ansible.git -e component_name=${var.ansible_role} -e env=${var.env} roboshop.yml"
        ]


    }
}

output "output" {
    value = data.vault_generic_secret.ssh.data["password"]
}