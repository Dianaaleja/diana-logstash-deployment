
# Diana-Logstash-Deployment 🚀

This project showcases my expertise in building a robust, scalable, and secure **Infrastructure as Code (IaC)** solution for deploying Logstash. It highlights the use of industry best practices, including modular Terraform design and Ansible for configuration management, to create a fully automated and auditable environment.

## Project Overview 🏗️

This repository provides a comprehensive solution for deploying a secure Logstash instance on AWS (or LocalStack for local development). The core principle of this project is to define the entire infrastructure and its configuration through code, establishing a **single source of truth** and enhancing security.

## Security & Compliance Focus (T.I.R. Principles) 🔒

This project prioritizes key security principles:

  * **Tampering & Information Disclosure:** By defining the entire environment and its configuration in code, we create an immutable infrastructure. This prevents unauthorized or un-audited manual changes (Tampering) and ensures security rules are consistently applied across the environment. Placing the Logstash instance in a private subnet, accessible only via a hardened bastion host, significantly minimizes its exposure to the public internet, thereby preventing unauthorized access and potential Information Disclosure.
  * **Repudiation:** Centralized and secure logging is a critical defense against repudiation. This infrastructure is designed to collect and protect comprehensive logs of all events, making it difficult for an actor to deny their actions. The secure deployment of Logstash is foundational to establishing this critical evidence trail.

## Architecture & Technologies ⚙️

This solution leverages the following technologies and architectural patterns:

  * **Terraform:** Used for provisioning the AWS infrastructure.
      * **Modular Design:** The Terraform configuration is structured using reusable modules (e.g., `/terraform/modules/networking`, `/terraform/modules/compute`) to promote reusability, maintainability, and clarity. The root `main.tf` orchestrates the deployment by calling these modules, rather than directly defining individual resources.
      * **Provisioned Resources:** The environment includes:
          * A Virtual Private Cloud (VPC) 🌐
          * Public and Private Subnets 🚧
          * A secure Bastion Host (jump server) 🛡️
          * A Logstash EC2 instance 🖥️
      * **Security Group Configuration:** The Logstash instance resides in a private subnet with precisely configured security group rules:
          * SSH access is allowed only from the Bastion Host. 🔑
          * Beats protocol ingress is allowed from application servers (where your data sources will reside). 📈
          * Egress rules permit communication to Elasticsearch or other log storage solutions. 📤
  * **Ansible:** Used for software installation and configuration management on the Logstash EC2 instance.
      * **Bastion Host as Proxy:** Ansible correctly utilizes the provisioned Bastion Host as an SSH proxy to securely configure the Logstash instance in the private subnet. 🔗

## Getting Started 🚀

To deploy this Logstash infrastructure, you will need to perform the following steps:

### Prerequisites ✅

  * **Terraform:** [Install Terraform](https://developer.hashicorp.com/terraform/downloads) on your local machine.

  * **Ansible:** Install Ansible, as it's used for the Logstash software installation.

    **Step 1: Install Ansible**
    You can install Ansible using your system's package manager.

      * **On macOS (using Homebrew):**
        ```bash
        brew install ansible
        ```
      * For other operating systems, refer to the [Ansible Installation Guide](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html).

### Configuration 📝

1.  **Terraform Variables (`terraform.tfvars`):**
    Navigate to the `/terraform` directory. You will find a `tfvars.example` file.

      * Copy `tfvars.example` to `terraform.tfvars`:
        ```bash
        cd terraform
        cp tfvars.example terraform.tfvars
        ```
      * Edit `terraform.tfvars` and provide the correct values for your deployment, such as your IP address for SSH access to the Bastion Host. This is crucial for the "Traditional SSH proxy" approach, which requires your Bastion Host's security group to allow incoming SSH traffic (port 22) from your specified IP.

2.  **Ansible Playbook (`/ansible/playbook.yml`):**
    This project includes an Ansible playbook to configure the Logstash instance.

      * Ensure the `playbook.yml` file is located in your `/ansible` directory:
        ```yaml
        # /ansible/playbook.yml
        ---
        - name: Install and Configure Logstash
          hosts: logstash
          become: true # This tells Ansible to use sudo for the tasks
          roles:
            - logstash
        ```

    This playbook is designed to tell Ansible which hosts to configure (`logstash`) and which role to apply (the `logstash` role, which contains the specific tasks for installing and configuring Logstash).

### Deployment 🚀

1.  **Initialize Terraform:**
    Navigate to the `/terraform` directory:

    ```bash
    cd terraform
    terraform init
    ```

2.  **Plan the Infrastructure:**
    Review the proposed changes before applying:

    ```bash
    terraform plan
    ```

3.  **Apply the Infrastructure:**
    Provision the AWS infrastructure:

    ```bash
    terraform apply
    ```

    Confirm with `yes` when prompted.

4.  **Run Ansible Playbook:**
    Once Terraform has finished provisioning the EC2 instance and Bastion Host, run the Ansible playbook from your project root or the `/ansible` directory. Ensure your `~/.ssh/config` is set up to proxy through the bastion or pass the appropriate `--ssh-extra-args` to `ansible-playbook` to utilize the bastion.

    ```bash
    # Example command, adjust as per your Ansible inventory and SSH config
    ansible-playbook -i <your_ansible_inventory_file> ansible/playbook.yml
    ```

    *Note: Your Ansible inventory needs to correctly reference the Logstash instance and configure the SSH proxy via the Bastion Host.*

### Local Testing with LocalStack (Optional) 🧪

If you have completed the LocalStack task, you can test and deploy this solution locally:

1.  Ensure LocalStack is running.
2.  Set the necessary AWS environment variables to point to LocalStack (e.g., `AWS_ACCESS_KEY_ID=test`, `AWS_SECRET_ACCESS_KEY=test`, `AWS_DEFAULT_REGION=us-east-1`, `LOCALSTACK_ENDPOINT=http://localhost:4566`).
3.  Execute `terraform apply` within the `/terraform` directory.
4.  Then, run `ansible-playbook` as described above to configure Logstash on the LocalStack-provisioned EC2 instance.

## Conceptual Understanding & Technical Documentation 📚

  * **Terraform Modules:**
      * [Official Terraform Documentation on Modules](https://developer.hashicorp.com/terraform/language/modules)
  * **Ansible for Configuration Management:**
      * [Red Hat: What is Configuration Management?](https://www.redhat.com/en/topics/automation/what-is-configuration-management)
  * **Ansible `dnf` module (for Amazon Linux 2023):**
      * [Ansible Builtin dnf module documentation](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/dnf_module.html)

-----

## Feedback & Contributions 💡

Your feedback on this code is highly valued\! This project is part of my personal repository, and I welcome any suggestions for improvement or best practices. Please feel free to open an issue or pull request.

-----