# Learnings

## What is an VPC and how does it manage subnets and why are they important? 

Virtual private cloud is a dedicated network where you would like to develop and deploy your application. Any user on internet would access the vpc via the internet gateway using its public ip. 
The CIDR notation: `10.0.0.0/16` means there are `16` bits that are fixed and other `16`, i.e. $2^{16}$ combination ready to be used. 
```
VPC (10.0.0.0/16)
│
├── Public Subnet (10.0.1.0/24)
│   └── Web Server (EC2)
│       - Public IP: 54.x.x.x
│       - Private IP: 10.0.1.10
│
├── Private Subnet (10.0.2.0/24)
│   └── Database Server (RDS)
│       - Private IP: 10.0.2.10
│
└── Internet Gateway
```

Let's break the CIDR blocks further and understand why the VPC and its subnets have different CIDR block. 

1. VPC CIDR (10.0.0.0/16):
``` 
/16 means first 16 bits are fixed
- Remaining bits (32-16 = 16 bits) can vary
- Available IPs = 2^16 = 65,536 addresses
- Range: 10.0.0.0 to 10.0.255.255
```
2. Subnet CIDR (10.0.1.0/24):
```
/24 means first 24 bits are fixed
- Remaining bits (32-24 = 8 bits) can vary
- Available IPs = 2^8 = 256 addresses
- Range: 10.0.1.0 to 10.0.1.255
```
The above calculations show that the subnet has to be a subset of the vpc, i.e. the IPs must be within the range defined by the CIDR block of the VPC. 