node {
  def acr = 'pythonexamapp.azurecr.io'
  def appName = 'whoami'
  def imageName = "${acr}/${appName}"
  def imageTag = "${imageName}:${env.BRANCH_NAME}.${env.BUILD_NUMBER}"
  def appRepo = "pythonexamapp.azurecr.io/whoami:1.0.0"
 
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
    
 
    // Roll out to production
    // changed ns name from production to master
    case "master":
        // Change deployed image in master to the one we just built
        sh("sudo kubectl --kubeconfig ~jenkins/.kube/config get ns prod || sudo kubectl --kubeconfig ~jenkins/.kube/config create ns prod")
        withCredentials([usernamePassword(credentialsId: 'acr_auth', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
          sh "sudo kubectl --kubeconfig ~jenkins/.kube/config -n prod get secret acr-auth || sudo kubectl --kubeconfig ~jenkins/.kube/config --namespace=prod create secret docker-registry acr-auth --docker-server ${acr} --docker-username $USERNAME --docker-password $PASSWORD"
        }
        sh("sed -i.bak 's#${appRepo}#${imageTag}#' ./k8s/production/*.yml")
        sh("sudo kubectl --kubeconfig ~jenkins/.kube/config --namespace=prod apply -f k8s/production/")
        sh("echo http://`kubectl --namespace=prod get service/${appName} --output=json | jq -r '.status.loadBalancer.ingress[0].ip'` > ${appName}")
        break

     }
  }
}