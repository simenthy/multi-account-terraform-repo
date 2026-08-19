cd accounts/<name>
terraform init -input=false -lockfile=readonly
terraform plan -input=false -out=tfplan.binary
terraform show -json tfplan.binary > tfplan.json
conftest test --policy ../../policy tfplan.json
rm -f tfplan.json tfplan.binary