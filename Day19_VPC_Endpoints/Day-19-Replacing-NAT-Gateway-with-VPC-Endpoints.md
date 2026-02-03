# Day 19 – Replacing NAT Gateway with VPC Endpoints (SSM)

## 🎯 Objective

Replace **NAT Gateway** usage for private EC2 instances by using **VPC Interface Endpoints**, enabling **AWS Systems Manager (SSM)** access without internet.

---

## 🧠 Architecture Overview

* EC2 in **Private Subnet**
* No Internet Gateway / NAT Gateway required
* Communication with AWS services via **Interface VPC Endpoints**
* Access EC2 using **Session Manager (SSM)**

---

## ✅ Prerequisites

### Create VPC

![App Screenshot](./images/vpc.png)
![App Screenshot](./images/vpc-2.png)

---
### VPC CIDR

The **VPC CIDR** is the IP range assigned to your VPC.

Example:

```
10.0.0.0/16
```

This is used in security group rules to allow internal VPC traffic.

---
### VPC Settings (VERY IMPORTANT)

Ensure the following are enabled on your VPC:

* ✅ DNS resolution
* ✅ DNS hostnames

**Path:**
VPC → Your VPCs → Select VPC → Actions → Edit VPC settings

![App Screenshot](./images/vpc-settings.png)
![App Screenshot](./images/vpc-settings-2.png)


---
### Subnet

![App Screenshot](./images/subnet.png)
![App Screenshot](./images/subnet-2.png)
![App Screenshot](./images/subnet-3.png)


---
### Root Table

![App Screenshot](./images/route-table.png)
![App Screenshot](./images/route-table-2.png)


### Security Group

![App Screenshot](./images/sg.png)
![App Screenshot](./images/sg-2.png)

---
### 3️⃣ IAM Role for EC2 (MANDATORY)

Create or use an IAM Role with:

**Policy attached:**

```
AmazonSSMManagedInstanceCore
```

Attach this role to the EC2 instance.

![App Screenshot](./images/roles.png)
![App Screenshot](./images/roles-2.png)
![App Screenshot](./images/roles-3.png)

---

## 🖥️ EC2 Instance Setup

* Subnet: **Private Subnet**
* Public IP: ❌ Disabled
* IAM Role: ✅ Attached (SSM role)
* Security Group:

  * Inbound: None required
  * Outbound: Allow all (or HTTPS 443)

![App Screenshot](./images/ec2.png)
![App Screenshot](./images/ec2-2.png)
![App Screenshot](./images/ec2-3.png)
![App Screenshot](./images/ec2-4.png)

---

## 🔌 VPC Endpoints to Create (3 REQUIRED)

### Security Group for Endpoints

⚠️ **Security Group MUST belong to the SAME VPC**

Inbound rule:

```
HTTPS (443) from VPC CIDR (e.g. 10.0.0.0/16)
```

Outbound:

```
Allow all
```

![App Screenshot](./images/sg-endpoint.png)
![App Screenshot](./images/sg-endpoint-2.png)
![App Screenshot](./images/sg-endpoint-3.png)

---

### Endpoint Configuration (Same for all 3)

* Type: **Interface**
* VPC: Same as EC2
* Subnet: Same private subnet as EC2
* Enable: ✅ Private DNS


---
### Interface Endpoints
Create **Interface Endpoints** for the following services:

```
com.amazonaws.<region>.ssm
```

![App Screenshot](./images/endpoint.png)
![App Screenshot](./images/endpoint-2.png)
![App Screenshot](./images/endpoint-3.png)
![App Screenshot](./images/endpoint-4.png)

```
com.amazonaws.<region>.ssmmessages
```

![App Screenshot](./images/endpoint-ssmmessage.png)
![App Screenshot](./images/endpoint-ssmmessage-2.png)
![App Screenshot](./images/endpoint-ssmmessages-3.png)
![App Screenshot](./images/endpoint-ssmmessage-4.png)

```
com.amazonaws.<region>.ec2messages
```
![App Screenshot](./images/endpoint-ec2.png)
![App Screenshot](./images/endpoint-ec2-2.png)
![App Screenshot](./images/endpoint-ec2-3.png)
![App Screenshot](./images/endpoint-ec2-4.png)



---
## Result

![App Screenshot](./images/ssm-connect.png)

---
## 🚫 Do We Need NAT Gateway?

❌ **NO** — NAT Gateway is NOT required for SSM when VPC Endpoints are used.

| Feature                     | NAT Needed?              |
| --------------------------- | ------------------------ |
| SSM Session Manager         | ❌ No                     |
| Private EC2 updates via SSM | ❌ No                     |
| Internet access             | ✅ Yes (only if required) |

---

## 🔐 EC2 Instance Connect Endpoint?

❌ **NOT REQUIRED** when using **SSM Session Manager**.

| Method | Requirement           |
| ------ | --------------------- |
| SSH    | Bastion / EC2 Connect |
| SSM    | IAM + Endpoints only  |

---

## 🔍 Validation Checklist

* [ ✅ ] EC2 shows **"Managed by SSM"**
* [ ✅ ] All 3 endpoints are **Available**
* [ ✅ ] Endpoint SG allows 443 from VPC CIDR
* [ ✅ ] IAM role attached to EC2
* [ ✅ ] DNS resolution + hostnames enabled

---

## 🧠 Key Learnings

* SSM requires **three endpoints**, not one
* Private DNS depends on VPC DNS settings
* Security Groups must match VPC of subnet
* NAT Gateway is optional when using VPC Endpoints

---

## 🏁 Final Result

✅ Private EC2 accessed securely via SSM

✅ No Internet Gateway

✅ No NAT Gateway

✅ AWS-recommended architecture

---

🔥 **Day 19 Completed – Production-grade private access achieved**
