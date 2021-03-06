#!/bin/bash

###################
### BUILD JAVA ####
###################

setting_variables () {
    sed -i "s/IMAGE_VERSION/${IMAGE_VERSION}/g" ./deployment.yaml
}

build_and_tag_docker () {
    docker build -t prd-matrix -f Dockerfile .
    docker tag prd-matrix:latest gcr.io/devops-273118/matrix:${IMAGE_VERSION}
    #docker tag noe-relatorio:latest gcr.io/devops-273118/matrix:latest
}

docker_push () {
	docker push gcr.io/devops-273118/matrix:${IMAGE_VERSION}
    #docker push gcr.io/devops-273118/matrix:latest
}

####################
### DEPLOY JAVA ####
####################

update_deployment () {
    kubectl apply -f deployment.yaml 
}

#################
### EXECUTION ###
#################

PIPELINE_STATUS=$1

case ${PIPELINE_STATUS} in
    build)
        setting_variables
        build_and_tag_docker
        docker_push
        ;;
    deploy)
        setting_variables
        build_and_tag_docker
        docker_push
        update_deployment
        ;;
    production-deploy)
        ;;
    hml-dev-production-deploy)
        ;;
    *)
        echo "############################################"
        echo "Select between build, or deploy"
        echo "############################################"
        ;;
esac
