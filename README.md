## 🏗️ 3-Tier Application on AWS (Terraform)

This project deploys a 3-tier architecture (Frontend, Backend, and Database) using Terraform on AWS Cloud.

## 📚 Architecture Overview

                ┌────────────────────────────┐
                │        Internet Users       │
                └─────────────┬───────────────┘
                              │
                   ┌──────────▼──────────┐
                   │   Public Subnets    │
                   │ (Bastion & ALBs)    │
                   └──────────┬──────────┘
                              │
                 ┌────────────▼────────────┐
                 │   Private Subnets       │
                 │ (Frontend + Backend)    │
                 └────────────┬────────────┘
                              │
                   ┌──────────▼──────────┐
                   │   Database Subnet   │
                   │     (RDS/MariaDB)   │
                   └─────────────────────┘


## 🚀 Features

1. VPC with public and private subnets across multiple AZs

1. Internet Gateway and NAT Gateway for secure routing

1. Bastion Host for SSH access

1. Frontend & Backend EC2 Instances in private subnets

1. RDS (MYSQL) in database subnet

1. Security Groups to control inbound and outbound traffic

1. Load Balancers for frontend and backend


## 🧩 Prerequisites

1. AWS Account

1. AWS CLI configured with a profile (e.g., dev)

1. Terraform v1.6+

1. IAM user with programmatic access

1. Key pair (optional if using Session Manager)