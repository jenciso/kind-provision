### To add prometheus-stack only

```shell
export $(cat .env.cluster-local | xargs)

envsubst < templates/external-dns.yaml | kubectl apply -f -

helm upgrade --install ingress-nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --namespace ingress-nginx --create-namespace \
  --set controller.service.annotations."external-dns\.alpha\.kubernetes\.io/hostname"=*.${CLUSTER_NAME}.${SITE_DOMAIN}

kubectl annotate ingressClass nginx ingressclass.kubernetes.io/is-default-class=true

kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.10.1/cert-manager.yaml

envsubst < templates/secret-cloudflare.yaml | kubectl apply -f -

kubectl wait -n cert-manager --for=condition=ready pod --selector=app.kubernetes.io/component=webhook --timeout=90s \
 && envsubst < templates/cluster-issuer.yaml | kubectl apply -f - \
 && envsubst < templates/certificate-wildcard.yaml | kubectl apply -f -

helm upgrade --install ingress-nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --namespace ingress-nginx --create-namespace \
  --set controller.service.annotations."external-dns\.alpha\.kubernetes\.io/hostname"=*.${CLUSTER_NAME}.${SITE_DOMAIN} \
  --set controller.extraArgs."default-ssl-certificate"=cert-manager/cert-wildcard

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

helm repo update prometheus-community

helm install prometheus --create-namespace --namespace prometheus prometheus-community/kube-prometheus-stack

helm upgrade prometheus prometheus-community/kube-prometheus-stack \
--namespace prometheus  \
--set prometheus.prometheusSpec.enableRemoteWriteReceiver=true \
--set prometheus.prometheusSpec.podMonitorSelectorNilUsesHelmValues=false \
--set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false

envsubst < templates/prometheus-ingress.yaml | kubectl apply -f -
envsubst < templates/grafana-ingress.yaml | kubectl apply -f -
envsubst < templates/alertmanager-ingress.yaml | kubectl apply -f -
```