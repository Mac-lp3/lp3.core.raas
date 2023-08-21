
## What it does

Each file

## TODO

* Policies are case sensitive. I could make things easier by updating the yml format and policy template so end users do not need to be aware of the proper field names/formats...

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