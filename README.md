# LP3 Core: RaaS (Roles as a Service)

Part of my personal "core infrastructure" for creating AWS roles in my account in the specific way I want.

## What it does

For each yaml file in the `projects/` folder, it:
    * Creates a user and role specifically for CICD actions.
    * Creats additional roles defined in the yaml.

### How it works

All AWS resources created by this project use a user named `core-raas-run-identity`.

It simply uses a terraform template to loop over each yaml file in the projects directory, scan for specific fields, and create each roles with the listed premissions.

In addition, each project will have one "deployer" user created as well. This user should be used for the CI/CD process. All depoloyers follow a specific naming convention (see below).

### Initial set up

Just run `make initial-setup`. You can provide a specific AWS region if you'd like.

This creates a terraform backend and an IAM user and role which the CI/CD or deployment process can use when creating users.

You can see the scripts in the `manual/` directory for the details.

### Tags

*Default tags*
env       = ${env}
managedBy = "raas"

### Conventions

*Naming conventions*
* deployers
    * users
        name: ${project_name}-deploy-user-${env}
        path: /lp3/raas/
    * policy
        name: ${project_name}-deploy-policy-${env}
        path: /lp3/raas/
    * role
        name: ${project_name}-deploy-role-${env}
        path: /lp3/raas/
    * role attachments
        name: ${project_name}-deploy-attachment-${env}
        path: /lp3/raas/

## TODO

* Manual scripts for tf backend, initial user set up & tagging
* Policies are case sensitive. I could make things easier by updating the yml format and policy template so end users do not need to be aware of the proper field names/formats...
* git deployments
    * non raas-user that will do the raas deployments