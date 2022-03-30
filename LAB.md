# LAB

## Creating a service nginx-demo

Creating a namespace "demos"

```
kubectl create ns demos
kubectl create deployment -n demos --image=nginx nginx-demo
kubectl create service -n demos clusterip nginx-demo --tcp=80:80
```

Creating an ingress entry

```
cat << EOF > /tmp/ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    kubernetes.io/ingress.class: "nginx"
    cert-manager.io/cluster-issuer: letsencrypt-prd-cloudflare
  name: nginx-demo
  namespace: demos
spec:
  rules:
  - host: nginx-demo.${CLUSTER_NAME}.${SITE_DOMAIN}
    http:
      paths:
      - pathType: Prefix
        path: /
        backend:
          service:
            name: nginx-demo
            port:
              number: 80
  tls:
  - hosts:
    - nginx-demo.${CLUSTER_NAME}.${SITE_DOMAIN}
    secretName: nginx-demo-cert
EOF
```
Or if you prefer, you can use the wildcard certificate

```
cat << EOF > /tmp/ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    kubernetes.io/ingress.class: "nginx"
  name: nginx-demo
  namespace: demos
spec:
  rules:
  - host: nginx-demo.${CLUSTER_NAME}.${SITE_DOMAIN}
    http:
      paths:
      - pathType: Prefix
        path: /
        backend:
          service:
            name: nginx-demo
            port:
              number: 80
  tls:
  - hosts:
    - nginx-demo.${CLUSTER_NAME}.${SITE_DOMAIN}
    secretName: cert-wildcard
EOF
```

Applying manifest

```
kubectl apply -f /tmp/ingress.yaml
```
