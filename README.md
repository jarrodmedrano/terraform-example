
# Terraform Learning

This repo is for learning terraform with AWS

### Helpful Commands

`terraform show`

Shows terraform state

`terraform show | grep -A 20 aws_vpc`

Show 20 lines after matching aws_vpc

`terraform state list`

lists all the resources in state

`terraform state show aws_instance.my_vm`

shows all attributes of a resource

`-replace`

safely recreates resources without destroying

Used when system malfunctions

`terraform plan -replace="aws_instance.my_vm"`

Will replace this one resource if you apply it.

`terraform apply -replace="aws_instance.my_vm"`


`terraform init`
`terraform console`
opens terraform console

type `local.common-tags`
to console log the variable

Reconfigure state

`terraform init -reconfigure -backend-config=backend.conf`

Migrating state

`terraform init -migrate-state`
