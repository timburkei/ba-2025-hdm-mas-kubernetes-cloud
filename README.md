Add your Azure Subscription ID in ./Iac-1/terraform.tfvars and ./Iac-2/terraform.tfvars

To start the project

```bash
az login
```

```bash
cd Iac-1
terraform init
terraform apply
```

```bash
cd ../IaC-2
terraform init
az aks get-credentials --resource-group thesis-25-hdm-stuttgart --name thesis-aks-cluster-hdm-25 --overwrite-existing
terraform apply -target=helm_release.keda
terraform apply
```

```bash
cd ../IaC-1
az aks disable-addons --addons virtual-node --resource-group thesis-25-hdm-stuttgart --name thesis-aks-cluster-hdm-25
az aks enable-addons --addons virtual-node --resource-group thesis-25-hdm-stuttgart --name thesis-aks-cluster-hdm-25 --subnet-name aci-subnet
```
