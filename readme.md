
Terraform v0.13.7
+ provider registry.terraform.io/hashicorp/aws v3.75.1
+ provider registry.terraform.io/hashicorp/template v2.2.0

That's complete solution to deploy application into kubernetes and which can be used inside cicd tools like Jenkins or something like that.

**All strings should included [A-Z and space]**



| key | value |
|--|--|
| bu | Business Unit |
| project | Project |
| env | Environment |
| PROVIDER-ROLE | ROLE where services will be provisioned |
| ARN-ROLE | ROLE where to create terraform backend |

**HELP SECTION**

    ./deploy --help
    

**How to provision services into AWS with DRY-RUN**

    ./deploy infraApply <bu-app> <env>


**How to deploy applications into AWS**

    ./deploy infraApply <bu-app> <env>
    
    
**How to destroy services in AWS with DRY-RUN**

    ./deploy infraDestroyPlan <bu-app> <env>
    
    
**How to destroy services in AWS with**

    ./deploy infraDestroy <bu-app> <env>

