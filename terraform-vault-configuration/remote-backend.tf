terraform {
  backend "remote" {
    hostname        = "https://magician.eastus.cloudapp.azure.com/"   #For SaaS use "app.terraform.io"
    organization    = "Zero-Trust"   #Your Org, top-left corner of the TFE UI
    workspaces {
      name = "Vault-auto"  #Workspace to connect to (lives within the Org)
    }
  }
}
