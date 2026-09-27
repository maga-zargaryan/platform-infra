# platform-infra

Foundational AWS networking and security for the Java platform.

## Terraform layout

```text
terraform/
├── modules/
│   ├── environment/       # reusable Dev/Prod VPC stack
│   └── shared-network/    # private Image Builder VPC network
├── environments/
│   ├── dev/                # platform/dev state
│   └── prod/               # platform/prod state
└── shared/
    └── image-builder/     # platform/shared state
```

Dev and Prod are separate root modules and states. The Image Builder network is shared infrastructure with its own state and is not a GitHub Environment.

The shared VPC has only private subnets, no Internet Gateway and no NAT Gateway. It uses VPC endpoints for Image Builder, SSM, SSM Messages, Secrets Manager, KMS, CloudWatch Logs and S3. AWS documents Image Builder private VPC builds through PrivateLink and requires access to its managed S3 resources.

## GitHub configuration

`development`, `production-plan`, and `production` remain GitHub Environments for Dev/Prod. Shared Image Builder networking is deployed by `deploy-shared.yml` using repository variable `AWS_SHARED_ROLE_ARN`; it is not a GitHub Environment.

Required Dev/Prod environment variables:
- `AWS_ROLE_ARN`
- `AWS_REGION`
- `VPC_CIDR`
- `AVAILABILITY_ZONES`
- `PUBLIC_SUBNET_CIDRS`
- `PRIVATE_APP_SUBNET_CIDRS`
- `PRIVATE_DB_SUBNET_CIDRS`
- `DOMAIN_NAME`
- `ROUTE53_ZONE_ID`

Required repository variables for shared networking:
- `AWS_REGION`
- `AWS_SHARED_ROLE_ARN`
- `SHARED_VPC_CIDR`
- `SHARED_AVAILABILITY_ZONES`
- `SHARED_PRIVATE_SUBNET_CIDRS`

No AWS access keys are stored in GitHub. Authentication uses OIDC.
