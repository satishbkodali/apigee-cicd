#!/bin/bash
AUTH_PASS="$1:$2"
deployment_info=$(curl -u $AUTH_PASS "https://api.enterprise.apigee.com/v1/organizations/$3/apis/$4/deployments") 

rev_num=$(jq -r .environment[0].revision[0].name <<< "${deployment_info}" ) 
env_name=$(jq -r .environment[0].name <<< "${deployment_info}" ) 
api_name=$(jq -r .name <<< "${deployment_info}" ) 
org_name=$(jq -r .organization <<< "${deployment_info}" )

declare -r num1=1
pre_rev=$(expr "$rev_num" - "$num1")

echo currRev=$rev_num
echo apiName=$api_name
echo orgName=$org_name
echo envName=$env_name
echo prevRev=$pre_rev

undeployRevUrl="https://api.enterprise.apigee.com/v1/organizations/$org_name/environments/$env_name/apis/$api_name/revisions/$rev_num/deployments"
delRevUrl="https://api.enterprise.apigee.com/v1/organizations/$org_name/environments/$env_name/apis/$api_name/revisions/$rev_num/deployments"
deployPrevRevUrl="https://api.enterprise.apigee.com/v1/organizations/$org_name/environments/$env_name/apis/$api_name/revisions/$pre_rev/deployments"

echo "undeploying recently deloyed revision $rev_num"
echo "DELETE call $undeployRevUrl"

curl -X DELETE -u $AUTH_PASS $undeployRevUrl

echo "Deleting recently deloyed revision $rev_num"
echo "DELETE call $delRevUrl"
curl -X DELETE -u $AUTH_PASS $delRevUrl

echo "Deploying previous revision $prev_rev again"
echo "POST call $deployPrevRevUrl"
curl -X POST --header "Content-Type: application/x-www-form-urlencoded" -u $AUTH_PASS $deployPrevRevUrl