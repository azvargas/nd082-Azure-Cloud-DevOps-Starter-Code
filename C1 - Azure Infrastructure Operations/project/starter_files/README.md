# Azure Infrastructure Operations Project: Deploying a scalable IaaS web server in Azure

### Introduction
For this project, you will write a Packer template and a Terraform template to deploy a customizable, scalable web server in Azure.

### Getting Started
This code is intended to generate all the necessary infrastructure on Azure using Terraform to deploy an availability set of web servers managed by a load balancer. The servers will be deployed from a custom Linux VM image generated using Packer.

### Dependencies
1. Create an [Azure Account](https://portal.azure.com) 
2. Install the [Azure command line interface](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
3. Install [Packer](https://www.packer.io/downloads)
4. Install [Terraform](https://www.terraform.io/downloads.html)
5. Register an application on Microsoft Entra and generate a secret.

### Instructions
1. Open a command prompt window in the project folder.
2. Set the environment variables needed by Packer to deploy the image:
   
   ARM_CLIENT_ID = The application ID of the registered application
   ARM_CLIENT_SECRET = The secret generated for the application
   ARM_SUBSCRIPTION_ID = The subscription ID
   
   The instructions to set these variables varies depending your operating system. For Windows PowerShell execute the following command:

   `$env:<variable> = "value"`
3. To deploy the server image execute:
   `packer build server.json`
4. Wait until Packer generates the image. This operation will last some minutes.
5. After Packer finishes, deploy the infrastructure using Terraform. To prepare the Terraform environment execute:
   `terraform init`
6. To generate the deployment plan, execute the following command:
   `terraform plan -out solution.plan`
   Terraform will ask you the username and password for the VM administrator, and the prefix used to name the objects.
7. After generating the plan, execute the following command to deploy the infrastructure:
   `terraform apply "solution.plan"`

### Customizing the variables
The file "vars.tf" contains the variables used to set different values related to the deployment. Some of them have default values. You can modify the "default" line on each variable to set a different default value. Terraform will ask for a value if the variable has no default value.

### Output
After applying the Terraform template, you should be able to view a "Hello, world!" message in your browser using the public IP generated on Azure.

