
#tls-values.yaml:
#    ./gen-certs.sh > tls-values.yaml

devinstall:
	helm upgrade sidecar helm/webhook-0.1.0.tgz --install --namespace webhooks --values k8s-tls-values.yaml  --values values.yaml


#   	helm upgrade --install --create-namespace -n webhooks --values tls-values.yaml --values values.yaml

helm-template:
	helm template sidecar chart --namespace webhooks --values k8s-tls-values.yaml  --values values.yaml \
		--output-dir helm-templates

uninstall:
	helm uninstall sidecar