# Kubernetes Mutating Admission Webhook - Python/Flask
A simple, and stupid, Admission Webhook written in Python. This package uses the Kubernetes MutatingWebhookConfiguration to choose what resources to modify (all new Pods in namespaces labelled with `environment: development` by default); *WARNING:* there is no further discrimination in the Python webhook - all Pods it 'reviews' will be mutated. The modifications to apply are specified in a ConfigMap in the form of a JSONPatch list.

# Using
This repo has a helpful script `gen-certs.sh` that can be used to create the `tls-values.yaml` file used in the two methods below.

If you'd like to modify the target namespace label(s), or alter the patches that are applied to the Pods, supply your own values file with something like this:
```yaml
config:
  targetNamespaceLabels:
    environment: development
  patchlist.json: |
    [
      {"op": "add", "path": "/metadata/annotations/mutating-webhook", "value": "success"}
    ]
```

## Method 1 - clone this repo
```bash
git clone https://github.com/ian-llewellyn/k8s-mutating-webhook-python
cd k8s-mutating-webhook

# Generate certs and CA bundle
./gen-certs.sh > tls-values.yaml

helm upgrade --install --create-namespace -n webhooks --values tls-values.yaml my-webhook chart
```

Now edit a namespace to include the label `environment: development`. When new Pods are created in this namespace, the supplied patches will be applied.

## Method 2 - Using Helm only
```bash
# Add this repo
helm repo add ian-llewellyn-mwh https://raw.githubusercontent.com/ian-llewellyn/k8s-mutating-webhook-python/master/helm

# Install the webhook - you must provide the TLS values and any other custom values
helm upgrade --install --create-namespace -n webhooks --values tls-values.yaml --values local-values.yaml mwh chart
```

Now edit a namespace to include the label `environment: development`. When new Pods are created in this namespace, the supplied patches will be applied.

# Known Issues
- It is not recommended to enable the webhook for the namespace in which it runs itself.
- The TLS values have to be supplied each time the chart is upgraded - the template should default to using a pre-existing secret.
- `hostNetwork: true` is required in some environments (Calico on EKS) - this is hardcoded but should instead be adjustable.
