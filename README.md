# platform-infra

Foundational AWS networking and security for the WordPress environments.

## Terraform layout

The `terraform/` directory contains only the platform resources:

- `backend.tf` — S3 remote state and native Terraform locking
- `providers.tf` — Terraform and AWS provider versions
- `variables.tf` — environment inputs and validation
- `network.tf` — VPC, public/private subnets and route tables
- `endpoints.tf` — S3 Gateway and required AWS Interface endpoints
- `kms.tf` — customer-managed workload encryption keys
- `dns.tf` — ACM certificate and Route53 DNS validation
- `outputs.tf` — IDs and ARNs consumed by later repositories

There are no environment-specific `.tfvars` files in the repository.

## Backend

`infra-bootstrap` creates the S3 state bucket. Replace the bucket placeholder in `terraform/backend.tf` once.

CI supplies the environment-specific state key:

- `platform/dev/terraform.tfstate`
- `platform/prod/terraform.tfstate`

The backend uses S3 native locking with `use_lockfile = true`; DynamoDB locking is not used.

## GitHub Environments

Create these GitHub Environments:

- `development` — Dev plan/apply and its AWS role/configuration
- `production-plan` — Prod planning only; no deployment approval should be configured here
- `production` — Prod apply; configure required reviewers here

Each environment used by a workflow provides the required non-secret variables:

- `AWS_ROLE_ARN`
- `AWS_REGION`
- `VPC_CIDR`
- `AVAILABILITY_ZONES` (JSON string)
- `PUBLIC_SUBNET_CIDRS` (JSON string)
- `PRIVATE_APP_SUBNET_CIDRS` (JSON string)
- `PRIVATE_DB_SUBNET_CIDRS` (JSON string)
- `DOMAIN_NAME`
- `ROUTE53_ZONE_ID`

AWS authentication uses GitHub OIDC. No AWS access keys or GitHub PAT are required.

## CI/CD flow

```text
Pull request
  -> fmt / validate / security scan
  -> Dev plan

Merge to main
  -> Dev apply
  -> Prod plan
  -> GitHub production approval
  -> Apply the exact reviewed Prod plan
```

Workflows are intentionally separated:

- `pull-request.yml` — validation, security scan and Dev plan
- `deploy-dev.yml` — Dev apply
- `plan-prod.yml` — Prod plan and immutable plan artifact
- `apply-prod.yml` — protected Prod apply of that exact artifact

The production plan and apply workflows use the commit SHA from the triggering workflow, so the reviewed plan is tied to the same repository revision that is applied.
