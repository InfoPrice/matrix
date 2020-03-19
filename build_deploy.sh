#!/bin/bash

#################
### VARIABLES ###
#################

setting_variables () {
    sed -i "s/FAMILY_NAME/${FAMILY_NAME}/g" ./deploy/"${CONFIG_FILE}".json
    sed -i "s/CONTAINER_NAME/${CONTAINER_NAME}/g" ./deploy/"${CONFIG_FILE}".json
    sed -i "s/ECR_NAME/${ECR_NAME}/g" ./deploy/"${CONFIG_FILE}".json
    sed -i "s/IMAGE_VERSION/${IMAGE_VERSION}/g" ./deploy/"${CONFIG_FILE}".json
    sed -i "s/CONTAINER_ESSENTIAL/${CONTAINER_ESSENTIAL}/g" ./deploy/"${CONFIG_FILE}".json
    sed -i "s/MEMORY/${MEMORY}/g" ./deploy/"${CONFIG_FILE}".json
    sed -i "s/CPU_LIMITS/${CPU_LIMITS}/g" ./deploy/"${CONFIG_FILE}".json
    sed -i "s/CONTAINER_PORT/${CONTAINER_PORT}/g" ./deploy/"${CONFIG_FILE}".json
    sed -i "s/HOST_PORT/${HOST_PORT}/g" ./deploy/"${CONFIG_FILE}".json
    sed -i "s/ENV_VALUE/${ENV_VALUE}/g" ./deploy/"${CONFIG_FILE}".json
    sed -i "s/SET_JAVA_XMX/${SET_JAVA_XMX}/g" ./deploy/"${CONFIG_FILE}".json
}

###################
### BUILD JAVA ####
###################

build_and_tag_docker () {
    docker build -t ${ECR_NAME} .
    docker tag ${ECR_NAME}:latest 199886244715.dkr.ecr.us-east-1.amazonaws.com/${ECR_NAME}:${IMAGE_VERSION}
}

build_docker_image () {
    build_and_tag_docker
    if [ $? -eq 0 ]; then
        echo "Build executed, pushing the image to Amazon Repository"
    else
        echo "Maven FAILED to compile, please check Jenkins errors"
        exit 1
    fi
}

docker_push () {
    docker push 199886244715.dkr.ecr.us-east-1.amazonaws.com/${ECR_NAME}:${IMAGE_VERSION}
}

push_docker_image () {
    docker_push
    if [ $? -eq 0 ]; then
        echo "Image pushed to Amazon Repository"
    else
        echo "push FAILED, please check Jenkins errors"
        exit 1
    fi
}

###################
### DEPLOY JAVA ###
###################

get_running_tasks () {
    DOCKER_STATUS=`aws ecs describe-services --cluster ${ECS_CLUSTER} --services ${ECS_SERVICE} --profile ${AWS_PROFILE} | jq '.services[] | .deployments[] | .runningCount' | sed 's/"//g'`
}

check_docker_status () {
    get_running_tasks
    while [ "${DOCKER_STATUS}" != "0" ]; do
        echo "############################################"
        echo "Current docker still running, waiting 5 seconds to start the new one"
        echo "############################################"
        sleep 5
        get_running_tasks
    done
    echo "############################################"
    echo "Current docker stopped, deploying the new version"
    echo "############################################"
}

deploy_status () {
    get_running_tasks
    while [ "${DOCKER_STATUS}" != "${ECS_TASK_NUMBER}" ]; do
        echo "############################################"
        echo "Docker is starting, waiting 10 seconds"
        echo "############################################"
        sleep 10
        get_running_tasks
    done
    echo "############################################"
    echo "All ${ECS_TASK_NUMBER} docker started"
    echo "############################################"
}

deploy_docker_image () {
    echo "####################################################"
    echo "## Deploy started on cluster ${ECS_CLUSTER} ##"
    echo "####################################################"
    echo "## Updating ${ECS_SERVICE} ##"
    echo "############################################"
    aws ecs update-service --cluster ${ECS_CLUSTER} --service ${ECS_SERVICE} --desired-count 0 --profile ${AWS_PROFILE}
    check_docker_status
    aws ecs update-service --cluster ${ECS_CLUSTER} --service ${ECS_SERVICE} --desired-count ${ECS_TASK_NUMBER} --profile ${AWS_PROFILE}
    #deploy_status
    echo "####################################################"
    echo "## New docker is launching on instances ##"
    echo "####################################################"
}

kill_task () {

    echo "Kill Tasks running"

    LIST_TASK=$(aws ecs list-tasks --profile "${AWS_PROFILE}" --cluster "${ECS_CLUSTER}" --service-name "${ECS_SERVICE}" --region us-east-1 | jq --raw-output .'taskArns | .[]')
    aws ecs stop-task --task $LIST_TASK --cluster "${ECS_CLUSTER}" --profile "${AWS_PROFILE}" --region us-east-1
    
    if [ $? -eq 0 ]; then
        echo "Task killed with success"
    else
        echo "There is no tasks running"
    fi
}

deploy_prod_docker_image () {

    TASK_DEFINITION=`aws ecs register-task-definition \
    --cli-input-json file://./deploy/"${CONFIG_FILE}".json \
    --network-mode "${NETWORK_MODE}" \
    --tags key=costs,value="${COST_CENTER}" \
    --profile "${AWS_PROFILE}" \
    | jq '.taskDefinition | .revision'`

    aws ecs update-service \
    --cluster "${ECS_CLUSTER}" \
    --service "${ECS_SERVICE}" \
    --desired-count "${ECS_TASK_NUMBER}" \
    --task-definition "${FAMILY_NAME}":"${TASK_DEFINITION}" \
    --deployment-configuration maximumPercent="${MAXIMUM_PERCENT}",minimumHealthyPercent="${MINIMUM_HEALTH}" \
    --profile "${AWS_PROFILE}"

    if [ $? -eq 0 ]; then
        echo "Service update with success"
    else
        echo "Error to update service"
        exit 1
    fi
}

#################
### EXECUTION ###
#################

PIPELINE_STATUS=$1

case ${PIPELINE_STATUS} in
    build)
        setting_variables
        compile_docker_image
        build_docker_image
        push_docker_image
        ;;
    deploy)
        deploy_docker_image
        ;;
    production-deploy)
        setting_variables
        build_docker_image
        push_docker_image
        deploy_prod_docker_image
        ;;
    hml-dev-production-deploy)
        setting_variables
        compile_docker_image
        build_docker_image_hml_dev
        push_docker_image
        kill_task
        deploy_prod_docker_image
        ;;
    *)
        echo "############################################"
        echo "Select between build, or deploy"
        echo "############################################"
        ;;
esac
