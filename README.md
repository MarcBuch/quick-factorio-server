# quick-factorio-server

Quickly deploy a factorio server to Azure with Terraform and Ansible.

## Factorio Server Features

You can apply all server settings you want in the `./ansible/server-settings.json`. The Ansible script will generate a random generated map. Savegames are currently not supported.

## Prerequisites

- An Azure subscription
- A valid Factorio account
- Terraform
- Ansible

## Getting started

1. Initialize terraform

```shell
$ tf init
```

2. Apply the Terraform configuration

```shell
$ tf apply
```

3. Copy the public IP returned from Terraform and append to `./ansible/hosts` file.

```shell
$ echo -e x.x.x.x >> ./ansible/hosts
```

4. Modify the Factorio server settings in `./ansible/server-settings.json`.

5. Run the Ansible playbook.

```shell
$ ansible-playbook ./ansible/configureFactorio.yml -i ./ansible/hosts
```
