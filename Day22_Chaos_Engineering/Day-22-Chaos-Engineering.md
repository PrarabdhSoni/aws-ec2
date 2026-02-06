# 📅 Day 22 – Chaos Engineering on AWS

## 🎯 Objective
To simulate real-world failures by automatically terminating random EC2 instances every 5 minutes and observing system recovery using Auto Scaling.

---

## 🧠 What is Chaos Engineering?

Chaos Engineering is the practice of intentionally introducing failures into a system to test its resilience, reliability, and fault tolerance.

It helps verify:
- High Availability
- Self-Healing Infrastructure
- Load Balancing Failover
- Monitoring & Alerting Effectiveness

---

## 🏗️ Architecture Used

|EventBridge (Scheduler)|
| --- |
| ↓ |
|Lambda Function|
| ↓ |
|Terminate Random EC2 Instance|
| ↓ |
| Auto Scaling Group Launches New Instance |

---

## ⚠️ Safety Measures

- Testing performed only in staging/test environment
- Instances tagged to avoid accidental deletion
- Auto Scaling Group used to maintain availability

---

## 🧱 Step 1 – Create Launch Template

### Configuration
- AMI: Amazon Linux 2
- Instance Type: t2.micro
- Security Group: Allow SSH and HTTP
- Key Pair: Optional

![App Screenshot](./images/launch-template.png)
![App Screenshot](./images/launch-template-2.png)
![App Screenshot](./images/launch-template-3.png)
![App Screenshot](./images/launch-template-4.png)

### Instance Tag
Key: Chaos

Value: True

![App Screenshot](./images/launch-template-5.png)

This ensures only selected instances are targeted.

---

## 🧱 Step 2 – Create Auto Scaling Group

### Configuration
- Launch Template: Created template
- Desired Capacity: 2
- Minimum Capacity: 2
- Maximum Capacity: 4

### Purpose
Ensures new instances are automatically launched when one is terminated.

![App Screenshot](./images/asg.png)
![App Screenshot](./images/asg-2.png)
![App Screenshot](./images/asg-3.png)
![App Screenshot](./images/asg-4.png)
![App Screenshot](./images/asg-5.png)
![App Screenshot](./images/asg-6.png)


---

## 🧱 Step 3 – Create IAM Role for Lambda

### Role Configuration
- Service: Lambda
- Policy Attached: AmazonEC2FullAccess

### Role Name

LambdaChaosRole

![App Screenshot](./images/roles.png)
![App Screenshot](./images/roles-2.png)
![App Screenshot](./images/roles-3.png)
![App Screenshot](./images/roles-4.png)

---

## 🧱 Step 4 – Create Lambda Function

### Runtime


Python 3.x

### IAM Role

Add IAM Role `LambdaChaosRole`

### Purpose
Randomly selects and terminates EC2 instances tagged with Chaos=True.

---

## 💻 Lambda Function Code

```python
import boto3
import random

ec2 = boto3.client('ec2')

def lambda_handler(event, context):

    response = ec2.describe_instances(
        Filters=[
            {
                'Name': 'tag:Chaos',
                'Values': ['True']
            },
            {
                'Name': 'instance-state-name',
                'Values': ['running']
            }
        ]
    )

    instances = []

    for reservation in response['Reservations']:
        for instance in reservation['Instances']:
            instances.append(instance['InstanceId'])

    if not instances:
        print("No instances found")
        return

    instance_to_kill = random.choice(instances)

    print(f"Terminating instance: {instance_to_kill}")

    ec2.terminate_instances(InstanceIds=[instance_to_kill])
```

![App Screenshot](./images/lambda.png)
![App Screenshot](./images/lambda-2.png)
![App Screenshot](./images/lambda-3.png)
![App Screenshot](./images/lambda-4.png)

---
## 🧱 Step 5 – Create EventBridge Scheduler

### Configuration
- Rule Type: Schedule
- Schedule Expression:
```
rate(5 minutes)
```

### Target

Lambda Function (Chaos Lambda)

![App Screenshot](./images/event-bridge.png)
![App Screenshot](./images/event-bridge-2.png)

Select Flexible time window = 5 minutes
![App Screenshot](./images/event-bridge-3.png)
![App Screenshot](./images/event-bridge-4.png)
![App Screenshot](./images/event-bridge-5.png)


---
## 🧪 Testing the Setup

1. Navigate to EC2 Dashboard
2. Observe running instances
3. Every 5 minutes:
    - One instance gets terminated
    - Auto Scaling launches replacement instance

![App Screenshot](./images/result.png)

---
## 📊 Observations

### Auto Scaling Activity
- Verified instance replacement logs
- Confirmed minimum capacity maintained

### CloudWatch Monitoring

- Monitored instance health
- Observed resource recovery

## Application Availability
- Load balancer redirected traffic successfully
- No downtime observed

---
## 🚀 Learning Outcomes
- Understood Chaos Engineering principles
- Implemented automated failure simulation
- Validated Auto Scaling self-healing capability
- Learned AWS EventBridge scheduling
- Implemented Lambda automation for infrastructure testing

---
## 🛑 Cleanup Steps

### To avoid unwanted resource usage:

- Delete EventBridge Rule
- Delete Lambda Function
- Delete Auto Scaling Group (Optional)

---
## 🌍 Real-World Industry Tools

- Netflix Chaos Monkey
- AWS Fault Injection Simulator
- Google DiRT Testing

---
## ✅ Conclusion

Chaos Engineering helps build highly reliable and fault-tolerant cloud infrastructure. This experiment validated automated recovery mechanisms and improved understanding of distributed system resilience.