# aws-cloud-technical-essentials

Contains exercises from coursera's course [Amazon DynamoDB: Building NoSQL Database-Driven Applications](https://www.coursera.org/learn/dynamodb-nosql-database-driven-apps)

## Infra
Infrastructure is managed using [Terraform's AWS provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs),
all the related code is under `infra` root folder.

The first time terraform has to be initialized using the following command
```shell
dynamodb-nosql-database-driven-apps/infra
$ terraform init
```
On every infrastructure modification changes can be applied with the following command
```shell
dynamodb-nosql-database-driven-apps/infra
$ terraform apply
```
