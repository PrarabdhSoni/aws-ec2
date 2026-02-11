    #!/bin/bash
    apt install-y httpd
    systemctl start httpd
    systemctl enable httpd
    echo "Hello from Terraform ASG" > /var/www/html/index.html