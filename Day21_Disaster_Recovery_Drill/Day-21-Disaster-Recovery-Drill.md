# ☁️ Day 21 – Disaster Recovery Drill (Full AZ Failure Simulation)

## 🎯 Objective
To simulate **Availability Zone (AZ) failure** and test system resilience using:
- Application Load Balancer (ALB)
- Multi-AZ architecture
- RDS Disaster Recovery simulation
- CloudWatch monitoring

---

## 🧠 Concept Overview

### What is Disaster Recovery?
Disaster Recovery (DR) ensures applications remain available during failures like:

- Availability Zone outage
- Server crash
- Database failure
- Network failure

---

### What is Availability Zone Failure?
An AZ failure means:
- Entire data center becomes unavailable
- EC2, RDS, and services inside that AZ stop working

---

## 🏗️ Architecture Used

| VPC |
| --- |
| ├── Public Subnet AZ-1 → EC2 Web Server 1 |
| ├── Public Subnet AZ-2 → EC2 Web Server 2 |
| ├── Application Load Balancer |
| ├── Primary RDS Database |
| └── Standby RDS Database (Manual DR) |


---

## ⚙️ Step 1 – VPC Setup

### Create VPC
- CIDR: `10.0.0.0/16`
- Name: `DR-VPC`

![App Screenshot](./images/vpc.png)
---

### Create Subnets

| Subnet | AZ | CIDR |
|----------|---------|-----------|
| Public-Subnet-1 | ap-south-1a | 10.0.1.0/24 |
| Public-Subnet-2 | ap-south-1b | 10.0.2.0/24 |

Public-Subnet-1
![App Screenshot](./images/vpc-subnet-1.png)
![App Screenshot](./images/vpc-subnet-1-2.png)

Public-Subnet-2
![App Screenshot](./images/vpc-subnet-2.png)
![App Screenshot](./images/vpc-subnet-2-2.png)

---

### Attach Internet Gateway
Route: `0.0.0.0/0 → Internet Gateway`

Attach to DR-VPC

![App Screenshot](./images/igw.png)
![App Screenshot](./images/igw-attach-vpc.png)

### Route Table

![App Screenshot](./images/rt.png)

Edit Routes

![App Screenshot](./images/edit-routes.png)
![App Screenshot](./images/edit-routes-2.png)

Associate both subnets `public-subnet-1` `public-subnet-2`

---

## 🖥️ Step 2 – Launch EC2 Instances

### Instance Deployment
| Instance | AZ |
|------------|---------|
| Web-Server-1 | AZ-1 |
| Web-Server-2 | AZ-2 |


Web-Server 1

![App Screenshot](./images/ec2-1.png)
![App Screenshot](./images/ec2-1-2.png)
![App Screenshot](./images/ec2-1-3.png)

WebServer 2

![App Screenshot](./images/ec2-2.png)
![App Screenshot](./images/ec2-2-2.png)

Attach same security group of WebServer 1

---

### Install Apache Web Server

In Both EC2 instance
```bash
sudo yum install httpd -y
sudo systemctl start httpd
sudo systemctl enable httpd
```

![App Screenshot](./images/https-commands.png)
![App Screenshot](./images/http-commands-2.png)

Create Identification Pages

- EC2 – AZ1 (WebServer 1)

```bash
echo "Server 1 - AZ1 Running" | sudo tee /var/www/html/index.html
```

![App Screenshot](./images/index-web1.png)

- EC2 – AZ2 (WebServer 2)

```bash
echo "Server 2 - AZ2 Running" | sudo tee /var/www/html/index.html
```
![App Screenshot](./images/index-web2.png)


---
## 🌐 Step 3 – Create Application Load Balancer

### Target Group
- Target Type: Instance
- Register both EC2 instances

![App Screenshot](./images/tg.png)
![App Screenshot](./images/tg-2.png)
![App Screenshot](./images/tg-3.png)
![App Screenshot](./images/tg-4.png)

### ALB
- Configuration
    - Type: Application Load Balancer
    - Scheme: Internet-facing
    - Subnets: Both AZs

- Health Check Path: /
    - Test Load Balancer

![App Screenshot](./images/lb.png)
![App Screenshot](./images/lb-2.png)
![App Screenshot](./images/lb-3.png)
![App Screenshot](./images/lb-4.png)
![App Screenshot](./images/lb-5.png)
![App Screenshot](./images/lb-6.png)

Access ALB DNS and verify traffic distribution between both servers.

### Modify Record (Domain Record)

Modify A record for accessing the website on your custom domain

![App Screenshot](./images/hosted%20zone.png)
![App Screenshot](./images/hosted-zone-2.png)

### Modify ALB Record

![App Screenshot](./images/modify-alb-security-group.png)
---
## 🗄️ Step 4 – Create Database Disaster Recovery (Free Tier Simulation)

Since Multi-AZ RDS is not part of Free Tier, manual DR simulation was performed.

![App Screenshot](./images/db.png)

1. Create Primary Database

- Identifier: dr-primary-db

- Engine: MySQL

- AZ: ap-south-1a

- Security Group Configuration

- Allow: `MySQL (3306) → Source: EC2 Security Group`

![App Screenshot](./images/db-1.png)
![App Screenshot](./images/db-1-2.png)
![App Screenshot](./images/db-1-3.png)
![App Screenshot](./images/db-1-4.png)
![App Screenshot](./images/db-1-5.png)
![App Screenshot](./images/db-sg.png)

2. Create Standby Database

- Identifier: dr-standby-db

- Engine: MySQL

- AZ: ap-south-1b

- Security Group Configuration

- Allow: `MySQL (3306) → Source: EC2 Security Group`

![App Screenshot](./images/db-2.png)
![App Screenshot](./images/db-2-2.png)
![App Screenshot](./images/db-2-3.png)
![App Screenshot](./images/db-sg.png)

## 🔗 Step 5 – Connect EC2 to Database

Install MySQL Client

```bash
sudo yum install mariadb105 -y
```

![App Screenshot](./images/mysql-install.png)

Connect to Primary Database

```bash
mysql -h PRIMARY-ENDPOINT -u admin -p
```

```sql
Create Test Data
CREATE DATABASE drtest;

USE drtest;

CREATE TABLE users(
 id INT PRIMARY KEY,
 name VARCHAR(50)
);

INSERT INTO users VALUES(1,"Primary Server");
```

![App Screenshot](./images/db-1-table.png)

---
## 🔄 Step 6 – Copy Data to Standby Database

Manual schema creation or data migration performed to simulate replication.


## 💥 Step 7 – Simulate AZ Failure

- Stop EC2 in AZ-1
- EC2 → Stop Web-Server-1

- Expected Result:
    - Traffic automatically shifts to AZ-2.

- Stop Primary Database
    - RDS → Stop dr-primary-db

## 🔁 Step 8 – Perform Manual Database Failover

Update connection to standby database:

```sql
mysql -h STANDBY-ENDPOINT -u admin -p
```

Verify data availability.

![App Screenshot](./images/db-2-out.png)

## 📊 Step 9 – Monitoring Using CloudWatch

Metrics Observed:

- Database connections
- CPU utilization
- Instance health
- Load balancer request count

## 🧪 Disaster Recovery Validation Checklist

|Test|	Expected Result|
| --- | ---|
|Stop AZ-1 EC2|	Traffic shifts to AZ-2|
|ALB Health Check|	Remaining instance healthy|
|Stop Primary DB|	Application fails temporarily|
|Switch to Standby DB|	Application recovers|
|User Downtime|	Minimal|

---
## 🧹 Step 10 – Restore Infrastructure

Start EC2 Again

```bash
sudo systemctl start httpd
```

Start Primary Database

Restart RDS instance and optionally sync data.

## 🧠 Key Learnings

- High availability architecture design
- Load balancer failover mechanism
- Manual database disaster recovery
- CloudWatch monitoring techniques
- AZ-level failure handling

---
## 🚀 Conclusion

Successfully simulated Availability Zone failure and validated application and database disaster recovery procedures, ensuring minimal downtime and data integrity.