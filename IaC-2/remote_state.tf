data "terraform_remote_state" "infrastructure" {
  backend = "local"
  config = {
    path = "../IaC-1/terraform.tfstate"
  }
}