## UNINSTALL

Delete the kind cluster and docker network

```
export CLUSTER_NAME=<your_cluster_name>   # demo
kind delete cluster --name ${CLUSTER_NAME}
docker network rm ${CLUSTER_NAME}
```
