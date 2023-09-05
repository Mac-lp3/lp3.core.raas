# LP3 Core: RaaS (Roles as a Service)

Part of my personal "core infrastructure" for creating AWS roles in my account in the specific way I want.

## What it does

For each yaml file in the `projects/` folder, it:
    * Creates a user and role specifically for CICD actions.
    * Creats additional roles defined in the yaml.

## How it works

All AWS resources created by this project use a user named `core-raas-run-identity`.

It simply uses a terraform template to loop over each yaml file in the projects directory, scan for specific fields, and create each roles with the listed premissions.

In addition, each project will have one "deployer" user created as well. This user should be used for the CI/CD process. All depoloyers follow a specific naming convention (see below).

## Development

**Contributing**

If you want to make changes to how the roles are deployed by the system (so changes to the scripts or the `.tf` files), then do not create featre branches - commit directly to the `main` branch. Pull requesst are treated as new role creation requests, and thus follow a different ci/cd workflow.

**Initial set up**

Just run `make initial-setup`. You can provide a specific AWS region if you'd like.

This creates a terraform backend and an IAM user and role which the CI/CD or deployment process can use when creating users.

You can see the scripts in the `manual/` directory for the details.

### Conventions

**Naming conventions**

All users and roles managed by this project will be created with the IAM path of `/lp3/raas/`.

Deployer users will follow the following naming convention: `${project_name}-deployer-user-${env}`.

Deployer roles will following the following naming convention: `${project_name}-deploy-role-${env}`.

## FAQ

**How do I use the deployer?**

One method is to use the AWS CLI `aws sts assume-role` command, extract the values from the returned JSON object, and export them via `export AWS_SESSION_TOKEN=...`.

The command must be run as the deployer user that was created (the only user with permission to assume that role). You need to log into the AWS console to get the user key and add it as a secret to your CI/CD jobs.

**The project doesn't have permission to create the role I just added. What do I do?**

Add the IAM permission to the policy document in `manual/1_user.sh`. Then, delete that role in the AWS console, and run the script to recreate it with the additional permission.

You should be good to go now (assuming that missing permission was your issue).

## TODO

* init TF workspace on branch create
* Reusable workflows for GH actions
* infra ci/cd triggered by tags or comments rather than direct commits?
* Policies are case sensitive. I could make things easier by updating the yml format and policy template so end users do not need to be aware of the proper field names/formats...