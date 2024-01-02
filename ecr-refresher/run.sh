#!/bin/bash
############ variables #############
CA_CERTIFICATE='/var/run/secrets/kubernetes.io/serviceaccount/ca.crt'
BEARER_TOKEN=`cat /var/run/secrets/kubernetes.io/serviceaccount/token`
NAMESPACE=`cat /var/run/secrets/kubernetes.io/serviceaccount/namespace`
while getopts "s:d:" option;
do
  case $option in
    s)
        TARGET_SECRET_NAMES=($OPTARG)
        ;;

    d)
        TARGET_DEPLOYMENT_NAMES=($OPTARG)
        ;;
  esac
done

echo "[$(date +%Y-%m-%dT%H:%M:%S%z)][INFO][PRINT_VAR][CA_CERTIFICATE] $CA_CERTIFICATE"
echo "[$(date +%Y-%m-%dT%H:%M:%S%z)][INFO][PRINT_VAR][BEARER_TOKEN] $BEARER_TOKEN"
echo "[$(date +%Y-%m-%dT%H:%M:%S%z)][INFO][PRINT_VAR][NAMESPACE] $NAMESPACE"
echo "[$(date +%Y-%m-%dT%H:%M:%S%z)][INFO][PRINT_VAR][TARGET_SECRET_NAMES] ${TARGET_SECRET_NAMES[@]}"
echo "[$(date +%Y-%m-%dT%H:%M:%S%z)][INFO][PRINT_VAR][TARGET_DEPLOYMENT_NAMES] ${TARGET_DEPLOYMENT_NAMES[@]}"
####################################

####### aws-cli-get-ecr-cred #######
ECR_PUSH_TOKEN=$(aws ecr get-login-password --region ap-northeast-2)

echo "[$(date +%Y-%m-%dT%H:%M:%S%z)][INFO][PRINT_VAR][ECR_PUSH_TOKEN] $ECR_PUSH_TOKEN"
####################################

########### patch-secret ###########
for TARGET_SECRET_NAME in "${TARGET_SECRET_NAMES[@]}"
do
    echo [$(date +%Y-%m-%dT%H:%M:%S%z)][INFO][PATCH_SECRET][START] $TARGET_SECRET_NAME
    
    curl -v \
      --cacert $CA_CERTIFICATE \
      -H "Authorization: Bearer $BEARER_TOKEN" \
      -H "Content-Type: application/json-patch+json" \
      -X PATCH \
      -d '[{"op": "replace", "path": "/data/DOCKER_REGISTRY_PASSWORD", "value": "'"$(echo -n $ECR_PUSH_TOKEN | base64 | tr -d '[:space:]')"'"}]' \
      https://kubernetes.default.svc/api/v1/namespaces/$NAMESPACE/secrets/$TARGET_SECRET_NAME
      
    echo [$(date +%Y-%m-%dT%H:%M:%S%z)][INFO][PATCH_SECRET][END] $TARGET_SECRET_NAME
done
####################################

######## restart-deployment ########
for TARGET_DEPLOYMENT_NAME in "${TARGET_DEPLOYMENT_NAMES[@]}"
do
    echo [$(date +%Y-%m-%dT%H:%M:%S%z)][INFO][RESTART_DEPLOYMENT][START] $TARGET_DEPLOYMENT_NAME

    curl -v \
      --cacert $CA_CERTIFICATE \
      -H "Authorization: Bearer $BEARER_TOKEN" \
      -H "Content-Type: application/strategic-merge-patch+json" \
      -X PATCH \
      -d '{"spec":{"template":{"metadata":{"annotations":{"kubectl.kubernetes.io/restartedAt":"'"$(date +%Y-%m-%dT%H:%M:%S%z)"'"}}}}}' \
      https://kubernetes.default.svc/apis/apps/v1/namespaces/$NAMESPACE/deployments/$TARGET_DEPLOYMENT_NAME \

    echo [$(date +%Y-%m-%dT%H:%M:%S%z)][INFO][RESTART_DEPLOYMENT][END] $TARGET_DEPLOYMENT_NAME
done
####################################