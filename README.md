Tyler McQueen's AKS project for Qualyfi.

To deploy, please run line:
./deploy/deploy.sh

Please ensure Docker is running locally before running deployment.

Spec/Requirements: 

- [x] Deploy a ‘free’ sku AKS cluster with a public control plane
- [x] Deploy the voting application: https://github.com/Azure-Samples/azure-voting-app-redis
- [x] Use a ‘basic’ sku ACR to store the application in your subscription and deploy from there
- [x] Use Linux node pools using the Mariner OS (Microsoft Linux)
- [x] Create two node pools, one for system and one for the application – use default sku for node pool vm’s which is ‘Standard_DS2_v2’
- [x] Use ‘containerd’ for the container runtime
- [x] Set the node pools to auto scale using the cluster autoscaler
- [x] Set the pods to auto scale using the horizontal pod autoscaler
- [x] Use an application namespace called ‘production’
- [x] Use Azure CNI networking with dynamic allocation of IPs and enhanced subnet support
- [x] Use AKS-managed Microsoft Entra integration, use the existing EID group ‘AKS EID Admin Group’ for Azure Kubernetes Service RBAC Cluster Admin access
- [x] Use Azure role-based access control for Kubernetes Authorization
- [x] Disable local user accounts
- [x] Use an Application Gateway for ingress traffic
- [x] Use a NAT gateway for internet egress traffic
- [x] Use a system assigned managed identity for the cluster
- [x] Use the Azure Key Vault provider to secure Kubernetes secrets in AKS, create an example secret and attach it to the backend pods
- [x] Use a ‘standard’ sku Bastion and public/private keys to SSH to the pods
- [x] Enable IP subnet usage monitoring for the cluster
- [x] Enable Container Insights for the cluster
- [x] Enable Prometheus Monitor Metrics and Grafana for the cluster

Success/Acceptance Criteria: 

- [x] Connect to the application front end via the App Gateway public ip
- [x] User node pool running without error with the front and back-end application
- [x] SSH to a node via the Bastion and the SSH keys
- [x] From the node load a web page via the NAT Gateway: curl ifconfig.me
- [x] Check cluster autoscaler logs for correct function of the cluster
- [x] Confirm the Pod autoscaler is running
- [x] Connect to a pod using kubectl bash command
- [x] Display the value of the example secret in the pod bash shell: kubectl exec azure-vote-front-684fc7679f-t9kdt --namespace (namespace) -- cat ./secrets-store-(front/back)/(secretName)
- [x] Check Container Insights is running, via the portal
- [x] Check Prometheus Monitor Metrics in Grafana instance
- [x] Use Azure Loading Testing to load the AKS cluster resulting in autoscaling of the nodes and pods: kubectl get pods --namespace (namespace)