# iofactory



### Terrafrom

This module will create vpc and ASG

```
terraform init
terraform plan
terraform apply
```

#### Ceveats 

- It is not possible with AWS NAT gateway to expose nginx. Either we need to host NAT gateway on ec2 and do the routing or need to use Loadbalacer in Public subnet.
- So i haven't wrote code to make route53 entries.



### Kubernetes

the directory contains all the files with appropriate commands.

