# Start
terraform init
# Check the terraform
terraform plan -var-file="dev.tfvars"
# Start deployment the terraform
terraform apply -var-file="dev.tfvars" -auto-approve
# Destroy
terraform destroy -auto-approve

######