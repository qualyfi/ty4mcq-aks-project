Tyler McQueen's AKS project for Qualyfi.

To deploy, please run line:
./deploy/deploy.sh

Please ensure Docker is running locally before running deployment.

Testing Methods

From the node load a web page via the NAT Gateway:
curl ifconfig.me

Connect to a pod using kubectl bash command:
kubectl exec --stdin --tty (podName) -- /bin/bash

Display the value of the example secret in the pod bash shell:
kubectl exec azure-vote-front-684fc7679f-t9kdt --namespace (namespace) -- cat ./secrets-store-(front/back)/(secretName)

Use Azure Loading Testing to load the AKS cluster resulting in autoscaling of the nodes and pods:
kubectl get pods --namespace (namespace)