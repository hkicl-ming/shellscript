#!/bin/bash

##################
# Local Variables
##################
CONTEXT_PREFIX_DEFAULT=default
CONTEXT_PREFIX_INPUT=
CONTEXT_ALIAS_INPUT=
AWS_EKS_CONFIG_FILE=


##################
# Find initial values
##################
PARENT_COMMAND=$(ps -o args= $PPID)
SCRIPT_NAME=$0
if [[ $PARENT_COMMAND == *"myaws.sh"* ]]; then
  SCRIPT_NAME="myaws.sh profile"
fi


##################
# Functions
##################
function funcUsage()
{
  echo "Usage: $SCRIPT_NAME [ options ]"
  echo " -c, --awsConfig <args> : AWS_EKS_CONFIG_FILE "
  echo " -a, --alias <args>     : Alias Name of context "
  echo " -p, --prefix <args>    : Prefix of context (default : ${CONTEXT_PREFIX_DEFAULT}) "
}

function funcParseArgs()
{
  for i in "$@"
  do
  case $i in
      -c=*|--awsConfig=*)
      AWS_EKS_CONFIG_FILE="${i#*=}"
      shift # past argument=value
      ;;
      -a=*|--alias=*)
      CONTEXT_ALIAS_INPUT="${i#*=}"
      shift # past argument=value
      ;;
      -p=*|--prefix=*)
      CONTEXT_PREFIX_INPUT="${i#*=}"
      shift # past argument=value
      ;;
      *)
            # unknown option
      funcUsage
      exit 0
      ;;
  esac
  done
}

##################
# Main
##################
if [[ ( $# -eq 0 ) || ( $# -gt 3 ) || ( $1 = "-h" || $1 = "--help" ) ]]; then
  funcUsage
  exit 0
fi

funcParseArgs $@

echo "AWS_EKS_CONFIG_FILE=$AWS_EKS_CONFIG_FILE"


CLUSTER=`awk '/  name:/{print}' $AWS_EKS_CONFIG_FILE | cut -d' ' -f 4`
REGION=`awk '/region:/{print}' $AWS_EKS_CONFIG_FILE | cut -d' ' -f 4`
CLUSTER_ARR=(${CLUSTER//-/ })

if  echo "${CLUSTER_ALIAS}" | grep -iqF cluster; then
  CLUSTER_ALIAS=${CLUSTER_ARR[1]}
  CONTEXT_PREFIX=${CLUSTER_ARR[2]}
else
  CLUSTER_ALIAS=${CLUSTER_ARR[0]}
  CONTEXT_PREFIX=${CLUSTER_ARR[1]}
fi
if [[ ! -z $CONTEXT_PREFIX_INPUT ]]; then
	CONTEXT_PREFIX=${CONTEXT_PREFIX_INPUT}
else
	CONTEXT_PREFIX=${CONTEXT_PREFIX_DEFAULT}
fi


if [[ ! -z $CONTEXT_ALIAS_INPUT ]]; then
  echo "not empty CONTEXT_ALIAS_INPUT=$CONTEXT_ALIAS_INPUT"
  CONTEXT_ALIAS=${CONTEXT_ALIAS_INPUT}
fi
echo "aws REGION=$REGION CLUSTER=$CLUSTER ALIAS=${CONTEXT_PREFIX}-${CONTEXT_ALIAS}"

# cat /dev/null > ~/.kube/config
aws eks --region ${REGION} update-kubeconfig --name ${CLUSTER} --alias ${CONTEXT_PREFIX}-${CONTEXT_ALIAS}

echo ""
echo "NOTE: You have switched to ${CLUSTER} with alias ${CLUSTER_ALIAS} located at ${REGION}."
echo ""

# kubectl get ns
kubectx
