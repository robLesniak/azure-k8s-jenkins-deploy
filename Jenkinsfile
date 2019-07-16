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
    case "dev":
        // Change deployed image in master to the one we just built
        sh("sudo kubectl --kubeconfig ~jenkins/.kube/config get ns dev || sudo kubectl --kubeconfig ~jenkins/.kube/config create ns dev")
        withCredentials([usernamePassword(credentialsId: 'acr_auth', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
          sh "sudo kubectl --kubeconfig ~jenkins/.kube/config -n dev get secret acr-auth || sudo kubectl --kubeconfig ~jenkins/.kube/config --namespace=dev create secret docker-registry acr-auth --docker-server ${acr} --docker-username $USERNAME --docker-password $PASSWORD"
        }
        sh("sed -i.bak 's#${appRepo}#${imageTag}#' ./k8s/dev/*.yml")
        sh("sudo kubectl --kubeconfig ~jenkins/.kube/config --namespace=dev apply -f k8s/dev/")
        sh("echo http://`kubectl --namespace=dev get service/${appName} --output=json | jq -r '.status.loadBalancer.ingress[0].ip'` > ${appName}")
        break

     }
  }
}