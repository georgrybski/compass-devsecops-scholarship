# Step 1: As-Is (Lift-and-Shift)

## Activities Required for Migration

1. **Inventory of on-premises resources and migration planning:**
    - Inventory servers, databases, storage, and current configurations.
    - Define the connectivity method (site-to-site VPN or AWS Direct Connect) between the on-premises environment and AWS, ensuring the route for replication via MGN and DMS.

2. **AWS MGN configuration for server replication:**
    - Install AWS MGN agents on the on-premises servers.
    - Configure continuous replication to migrate servers to EC2 instances with low latency for the cutover.
    - Ensure that connectivity between on-premises and AWS is operational (via VPN or Direct Connect) to support replication.

3. **AWS DMS configuration for database migration:**
    - Configure DMS to perform the initial load from MySQL to Amazon RDS.
    - Enable CDC (Change Data Capture) to synchronize transactions during migration.
    - Store database credentials in **AWS Secrets Manager**, with encryption managed by **AWS KMS**, for enhanced security.

4. **Creation of the necessary VPC, subnets, and security groups:**
    - Create a VPC with CIDR 10.0.0.0/16.
    - Within the VPC, create the following subnets **in the same Availability Zone**:
        - **Public Subnet:** To host the front-end EC2 instance and the NAT Gateway.
            - Suggested name: fasteng-prod-public-az1
        - **Private Subnet:** To host the back-end EC2 instance and Amazon RDS.
            - Suggested name: fasteng-prod-private-az1
    - Configure **Security Groups**:
        - fasteng-prod-sg-front-end: Applied to the front-end EC2 instance, allowing HTTP/HTTPS traffic from the Internet.
        - fasteng-prod-sg-back-end: Applied to the back-end EC2 instance, allowing communication only with the front-end.
        - fasteng-prod-sg-rds: Applied to the RDS, permitting access only from the back-end instance.

5. **Execution of replication and verification of migrated data integrity:**
    - Execute replication via AWS MGN and DMS.
    - Run tests to verify the integrity of the migrated data.

6. **Testing and validation of migrated servers and databases:**
    - Perform performance, integration, and usability tests in the AWS environment.
    - Validate communication between the front-end instance, the back-end instance, and the database.

7. **Decommissioning of the old on-premises environment after validation:**
    - Once it is confirmed that the AWS environment is functioning correctly, decommission the on-premises resources.

## Tools Utilized

- **AWS MGN:** To migrate on-premises servers to EC2 instances.
- **AWS DMS:** To migrate and replicate the MySQL database to Amazon RDS.
- **Amazon EC2:** Hosts the front-end (React) and back-end (APIs with Nginx) instances.
    - *Note:* Without a load balancer, as the two instances will alternate (one redirects to the other) to handle the load.
- **Amazon RDS:** Managed MySQL database with high availability (Multi-AZ is not required at this stage, but can be enabled in the future).
- **AWS IAM, Security Groups, and Network ACLs:** For access control, security, and network isolation.
- **AWS Secrets Manager:** For secure storage of credentials (e.g., database passwords).
- **AWS KMS:** Manages encryption keys for EBS, RDS, Secrets Manager, and other resources.
- **AWS Cost Calculator:** To estimate the infrastructure costs on AWS.

## AWS Infrastructure Diagram (Step 1)

*(The diagram illustrates the VPC with public and private subnets, EC2 front-end, EC2 back-end, RDS, NAT Gateway, MGN, and DMS for migration.)*

![Infra Lift   Shift Doc](https://github.com/user-attachments/assets/c5b77be5-434a-4426-b405-7daa85c81b01)

### Diagram Description

- **VPC (10.0.0.0/16)**
    - **Public Subnet (AZ1):**
        - **Internet Gateway** connected to the VPC.
        - **NAT Gateway** to allow resources in the private subnet to access the internet.
        - **EC2 Instance – Front-End:** Serving the React application.
    - **Private Subnet (AZ1):**
        - **EC2 Instance – Back-End:** Hosts the APIs and Nginx that redirects to the front-end instance as needed.
        - **Amazon RDS – MySQL:** Managed database.
    - **Other Services:**
        - **AWS MGN and DMS:** Configured for migration, with access to the VPC.
        - **AWS IAM:** Manages policies and permissions (global service).
        - **AWS Cost Calculator:** Used externally for cost estimates.

## Security Requirements Assurance

- **Access Control:**
    - Use Security Groups to limit traffic between the front-end, back-end, and RDS.
    - Apply IAM roles with the minimum necessary permissions for each resource.
- **Data Protection:**
    - **Encryption at rest** (EBS, RDS) using **AWS KMS**.
    - **Encryption in transit** (TLS/SSL) for database and service access.
    - **Credential storage** in **AWS Secrets Manager**, with keys managed by KMS.
- **Auditing and Monitoring:**
    - Use **AWS CloudTrail** to log all actions.
    - Use **AWS Config** to monitor configuration changes.
- **Firewalls and ACLs:**
    - Configure **Network ACLs** to reinforce subnet security.
- **Backups:**
    - Automated backups in RDS (daily snapshots) and EBS.
    - Use **AWS Backup** to manage backup and retention policies.

## Backup Process

- **Amazon RDS:**
    - Daily automatic backups (with retention configured, e.g., 7 to 30 days).
    - Manual snapshots after migration to provide an immediate recovery point.
- **EC2 and EBS:**
    - Use **AWS Backup** for regular snapshots of EBS volumes.
- **Static Files:**
    - If there are local files, they can be migrated to an S3 bucket with versioning for protection.

## Cost Estimate (AWS Calculator)

- **EC2:** Based on t3.small instances for the front-end and t3.medium for the back-end.
- **RDS:** A db.m5.xlarge instance or similar, with additional costs for storage and snapshots.
- **Other:** NAT Gateway, data transfer, and operational costs for AWS MGN and DMS.
- **Total Approximate:** Around **$300/month** for the temporary Step 1 configuration.

---

# Step 2: Modernization to AWS (EKS and Managed Services)

## Activities Required for Modernization

1. **Infrastructure as Code Setup:**
    - Use **Terraform** and/or **AWS CloudFormation** to define the entire infrastructure.
2. **Creation of the Kubernetes Cluster on Amazon EKS:**
    - Provision an EKS cluster within the VPC.
    - Distribute EKS nodes across private subnets in two AZs for high availability.
    - Launch the nodes (worker nodes) via an **Auto Scaling Group** to adjust capacity based on demand.
3. **CI/CD Setup:**
    - Implement an automated pipeline with **AWS CodePipeline**, **CodeBuild**, and **CodeDeploy/ECR**.
    - Integrate with a repository (such as GitHub) to trigger builds and deployments.
4. **Deployment of Microservices:**
    - Containerize the front-end and back-end.
    - For the front-end, build the static artifacts (HTML, JS, CSS) and upload them to an S3 bucket; these files will be distributed via **CloudFront**.
    - For the back-end, create **Deployments** (or other workload objects) in EKS to manage the pods.
5. **Auto-scaling Configuration:**
    - Enable **Auto Scaling** for the EKS nodes (via ASGs) and use the **Horizontal Pod Autoscaler (HPA)** to adjust the number of pods based on load.
    - Optionally configure auto-scaling for the database (if necessary) and adjust S3 resources based on demand.
6. **Implementation of Monitoring, Security, and Backup:**
    - Configure **Amazon CloudWatch** for monitoring, logging, and alerts.
    - Configure **AWS WAF** and **AWS Shield** to protect endpoints (CloudFront and/or ALB).
    - Configure **AWS Backup** and retention policies for EKS, RDS, and persistent volumes.

## Tools Utilized

- **Amazon EKS:** Container orchestration with Kubernetes.
- **Amazon RDS (Multi-AZ):** Managed MySQL database with high availability.
- **Amazon S3:** Storage for images, static files, and front-end artifacts.
- **AWS CodePipeline, CodeBuild, ECR, and CodeDeploy:** CI/CD pipeline services to automate builds, tests, and deployments.
- **AWS Auto Scaling:** To automatically scale EKS nodes and other resources.
- **AWS IAM and Secrets Manager:** For managing credentials and permissions, especially with **IRSA** for EKS pods.
- **AWS CloudWatch and GuardDuty:** For monitoring and security of the environment.
- **AWS EFS:** Optional, for shared persistent storage integrated with EKS.
- **AWS KMS:** Used for encrypting data at rest in S3, EBS, RDS, and for secrets in Secrets Manager.

## AWS Infrastructure Diagram (Step 2)

*(The diagram represents an environment distributed across multiple AZs, with public and private subnets, EKS, RDS Multi-AZ, CloudFront, NAT Gateways, etc.)*

![Modern Infrastructure Doc](https://github.com/user-attachments/assets/642b5aa4-0de8-4502-8740-dec315e5396e)

### Diagram Description

- **VPC (10.0.0.0/16)**
    - **Public Subnets (in AZ1 and AZ2):**
        - **Internet Gateway**.
        - **NAT Gateways:** One NAT Gateway per AZ (in each public subnet) to allow private nodes to access the internet for updates and image pulls.
        - **CloudFront:** Distribution pointing to the S3 bucket hosting the front-end.
    - **Private Subnets (in AZ1 and AZ2):**
        - **Amazon EKS Cluster:**
            - The EKS cluster is created within the VPC.
            - Worker nodes are distributed across private subnets in both AZs for high availability.
            - **IRSA:** Applied to ensure that pods have the minimum required IAM permissions.
        - **Amazon RDS (Multi-AZ):**
            - Managed MySQL database with read replicas for improved performance.
    - **Other Global Services (not tied to the VPC):**
        - **AWS IAM:** Manages permissions globally.
        - **AWS WAF/Shield:** Protects public resources (CloudFront, ALB if used).
        - **AWS CodePipeline/CodeBuild/CodeDeploy/ECR:** CI/CD services.
        - **AWS CloudWatch:** Centralizes monitoring and logging.
        - **AWS Secrets Manager:** Securely stores secrets (database passwords, API tokens, etc.), encrypted with **KMS**.

## Security Requirements Assurance (Step 2)

- **Network Controls:**
    - Use Security Groups, Network ACLs, and Kubernetes Network Policies to control traffic.
- **Authentication and Authorization:**
    - Apply IAM roles and **IRSA** to ensure that pods have minimal necessary access.
- **Endpoint Protection:**
    - Implement **AWS WAF** and **AWS Shield** on **CloudFront** and, if applicable, on the ALB to block attacks.
- **Encryption:**
    - Encrypt data in transit and at rest (S3, RDS, EBS) using **AWS KMS**.
- **Monitoring and Auditing:**
    - Use CloudWatch, GuardDuty, CloudTrail, and AWS Config for continuous monitoring and auditing.

## Backup and DR Process (Step 2)

- **Database (RDS):**
    - Daily automatic backups with configured retention.
    - Manual snapshots and use of **AWS Backup** for centralized policies.
- **EKS and Persistence:**
    - Backups of EBS volumes (used by pods with persistent storage) via **AWS Backup**.
    - Versioning of files in the S3 bucket with optional replication for increased resilience.
- **DR:**
    - High availability ensured by Multi-AZ.
    - Backup and recovery strategy within a single region, with the possibility to replicate critical snapshots to another region if necessary.

---

## Migration Cost in AWS Cost Calculator

- **[Migration Estimate](https://calculator.aws/#/estimate?id=df13a1f275762797f92adabc00c76913b5d0163a)**
- [**Modernization Estimate**](https://calculator.aws/#/estimate?id=946c4eb8395e879164fa5ef49d6b9beafb9516c1)