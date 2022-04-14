#!/bin/sh

# EXIT on error
set -e

declare -A envsAvailable=( [ALB]=Albania [BHR]=Bahrain [CMR]=Cameroon [DNK]=Denmark [EGY]=Egypt )

# Performs a local run with a giving envirionment
local_run(){
    echo "=============================="
    echo "|                            |"
    echo "| CREATE A *DEV* GCP PROJECT |"
    echo "|                            |"
    echo "=============================="

    printf '\n======== First Terraform Init ========\n'
    terraform init

    printf '\n======================================\n'
    printf 'should proceed with terraform plan? (y/n):'
    read plan
    printf '\n'

    if [[ "$plan" == "y" ]]; then
        echo "======== First Terraform Plan ========"
        terraform plan -var-file shared/shared.tfvars
    else
        exit 1
    fi

    printf '\n======================================\n'
    printf "should proceed with terraform aplly? (y/n):"
    read apply
    printf '\n'

    if [[ "$apply" == "y" ]]; then
        echo "======== First Terraform plan ========"
        terraform apply -var-file shared/shared.tfvars -auto-approve
    fi

    printf '\n======================================\n'
    printf "should proceed with terraform state migration? (y/n):"
    read migration
    printf '\n'

     if [[ "$migration" == "y" ]]; then
        echo "======== Terraform State Migration ========"
        terraform init -backend-config eval/backend.hcl -migrate-state
    fi

    printf "Done"


}

first_run(){    
    
    
    envsToBeCreated=()

    case $1 in
        # all)
        #     envsToBeCreated+=("${envsAvailable[dev]}")
        #     envsToBeCreated+=("${envsAvailable[staging]}")
        #     envsToBeCreated+=("${envsAvailable[prod]}")
        #     ;;
        # # dev_prod)
        #     envsToBeCreated+=(envsAvailable['dev'])
        #     envsToBeCreated+=(envsAvailable['prod'])
        #     ;;
        # staging)
        #     envsToBeCreated+=( envsAvailable["staging"] )
        #     ;;
        # prod)
        #     envsToBeCreated+=( envsAvailable["prod"] )
        #     ;;
        # \?)
        #     envsToBeCreated+=("${envsAvailable["dev"]}")
        #     ;;
        # *)
        #     envsToBeCreated+=("${envsAvailable[dev]}")
        #     ;;
    esac
    
    echo "${envsAvailable[*]}"
    # for envs in "${!envsToBeCreated[@]}"; do 
    #     echo "$envs - ${envsToBeCreated[$envs]}"; 
    # done
}

init() {
    echo "======== Terraform Init ========"
    terraform init -backend-config eval/backend.hcl
}

plan() {
    echo "======== Terraform plan ========"
    terraform plan -var-file shared/shared.tfvars
}

apply(){
    echo "======== Terraform apply ========"
    terraform apply -var-file shared/shared.tfvars -auto-approve
}


default() {
    echo "Test"
}

# END tasks
# //////////////////////////////////////////////////////////////////////////////

${@:-default}