node {
  def acr = 'acrdemo11.azurecr.io'
  def appName = 'whoamiapp'
  def imageName = "${acr}/${appName}"
  def imageTag = "${imageName}:${env.BRANCH_NAME}.${env.BUILD_NUMBER}"
  def appRepo = "acrdemo11.azurecr.io/whoami_app:v1.0.0"
 
  checkout scm
 
 stage('Build the Image and Push to Azure Container Registry')
 {
   app = docker.build("${imageName}")
   withDockerRegistry([credentialsId: 'acr_auth', url: "https://${acr}"]) {
      app.push("${env.BRANCH_NAME}.${env.BUILD_NUMBER}")
                }
  }
 
 
 stage ("Deploy Application on Azure Kubernetes Service")
 {
  switch (env.BRANCH_NAME) {
    // Roll out to canary environment
    case "canary":
        // Change deployed image in canary to the one we just built
         sh("sudo kubectl --kubeconfig ~jenkins/.kube/config get ns ${appName}-${env.BRANCH_NAME} || sudo kubectl --kubeconfig ~jenkins/.kube/config create ns ${appName}-${env.BRANCH_NAME}")
        withCredentials([usernamePassword(credentialsId: 'acr_auth', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
          sh "sudo kubectl --kubeconfig ~jenkins/.kube/config -n ${appName}-${env.BRANCH_NAME} get secret acr-auth || sudo kubectl --kubeconfig ~jenkins/.kube/config --namespace=${appName}-${env.BRANCH_NAME} create secret docker-registry acr-auth --docker-server ${acr} --docker-username $USERNAME --docker-password $PASSWORD"
        }
        sh("sed -i.bak 's#${appRepo}#${imageTag}#' ./k8s/production/*.yml")
        sh("sudo kubectl --kubeconfig ~jenkins/.kube/config --namespace=${appName}-${env.BRANCH_NAME} apply -f k8s/production/")
        sh("echo http://`kubectl --namespace=${appName}-${env.BRANCH_NAME} get service/${appName} --output=json | jq -r '.status.loadBalancer.ingress[0].ip'` > ${appName}")
        break
 
    // Roll out to production
    // changed ns name from production to master
    case "master":
        // Change deployed image in master to the one we just built
        sh("sudo kubectl --kubeconfig ~jenkins/.kube/config get ns ${appName}-${env.BRANCH_NAME} || sudo kubectl --kubeconfig ~jenkins/.kube/config create ns ${appName}-${env.BRANCH_NAME}")
        withCredentials([usernamePassword(credentialsId: 'acr_auth', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
          sh "sudo kubectl --kubeconfig ~jenkins/.kube/config -n ${appName}-${env.BRANCH_NAME} get secret acr-auth || sudo kubectl --kubeconfig ~jenkins/.kube/config --namespace=${appName}-${env.BRANCH_NAME} create secret docker-registry acr-auth --docker-server ${acr} --docker-username $USERNAME --docker-password $PASSWORD"
        }
        sh("sed -i.bak 's#${appRepo}#${imageTag}#' ./k8s/production/*.yml")
        sh("sudo kubectl --kubeconfig ~jenkins/.kube/config --namespace=${appName}-${env.BRANCH_NAME} apply -f k8s/production/")
        sh("echo http://`kubectl --namespace=${appName}-${env.BRANCH_NAME} get service/${appName} --output=json | jq -r '.status.loadBalancer.ingress[0].ip'` > ${appName}")
        break

     case "release":
        // Change deployed image in master to the one we just built
        sh("sudo kubectl --kubeconfig ~jenkins/.kube/config get ns ${appName}-${env.BRANCH_NAME} || sudo kubectl --kubeconfig ~jenkins/.kube/config create ns ${appName}-${env.BRANCH_NAME}")
        withCredentials([usernamePassword(credentialsId: 'acr_auth', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
          sh "sudo kubectl --kubeconfig ~jenkins/.kube/config -n ${appName}-${env.BRANCH_NAME} get secret acr-auth || sudo kubectl --kubeconfig ~jenkins/.kube/config --namespace=${appName}-${env.BRANCH_NAME} create secret docker-registry acr-auth --docker-server ${acr} --docker-username $USERNAME --docker-password $PASSWORD"
        }
        sh("sed -i.bak 's#${appRepo}#${imageTag}#' ./k8s/stage/*.yml")
        sh("sudo kubectl --kubeconfig ~jenkins/.kube/config --namespace=${appName}-${env.BRANCH_NAME} apply -f k8s/stage/")
        sh("echo http://`kubectl --namespace=${appName}-${env.BRANCH_NAME} get service/${appName} --output=json | jq -r '.status.loadBalancer.ingress[0].ip'` > ${appName}")
        break
 
    // Roll out a dev environment
    default:
        // Create namespace if it doesn't exist
        sh("sudo kubectl --kubeconfig ~jenkins/.kube/config get ns ${appName}-${env.BRANCH_NAME} || kubectl create ns ${appName}-${env.BRANCH_NAME}")
        withCredentials([usernamePassword(credentialsId: 'acr_auth', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
          sh "sudo kubectl --kubeconfig ~jenkins/.kube/config -n ${appName}-${env.BRANCH_NAME} get secret acr-auth || kubectl --namespace=${appName}-${env.BRANCH_NAME} create secret docker-registry acr-auth --docker-server ${acr} --docker-username $USERNAME --docker-password $PASSWORD"
        }  
        sh("sed -i.bak 's#${appRepo}#${imageTag}#' ./k8s/dev/*.yml")
        sh("sudo kubectl --kubeconfig ~jenkins/.kube/config --namespace=${appName}-${env.BRANCH_NAME} apply -f k8s/dev/")
        echo 'To access your environment run `kubectl proxy`'
        echo "Then access your service via http://localhost:8001/api/v1/namespaces/${appName}-${env.BRANCH_NAME}/services/${appName}:80/proxy/"    
    }
  }
}