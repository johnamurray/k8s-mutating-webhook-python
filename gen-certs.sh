#!/bin/bash
NAMESPACE=${1:-webhooks}
RELEASE=${2:-mwh}
CHART=webhook
DIRNAME=$(dirname $0)
STS=$(echo -en '\e[33m')
RST=$(echo -en '\e[m')

sts() {
  echo $STS$@$RST >&2
}

sts ">> Generating the CA private key..."
openssl genrsa -out ca.key 2048 >&2

sts
sts ">> Generating a self-signed CA certificate.."
openssl req -new -x509 -days 365 -key ca.key \
  -subj "/C=AU/CN=simple-kubernetes-webhook"\
  -out ca.crt >&2

sts
sts ">> Generating the web-server private key and certificate signing request..."
openssl req -newkey rsa:2048 -nodes -keyout server.key \
  -subj "/C=AU/CN=simple-kubernetes-webhook" \
  -out server.csr >&2

sts
sts ">> Signing the CSR to generate the web-server certificate..."
openssl x509 -req \
  -extfile <(printf "subjectAltName=DNS:$RELEASE-$CHART.$NAMESPACE.svc") \
  -days 365 \
  -in server.csr \
  -CA ca.crt -CAkey ca.key -CAcreateserial \
  -out server.crt >&2

sts
sts ">> Creating TLS values file for Helm deployment"
echo -e "tls:\n  certificate: |"
sed 's/^/    /g' server.crt
echo "  key: |"
sed 's/^/    /g' server.key
echo -n "  caBundle: \""
cat ca.crt | base64 | tr -d '\n'
echo "\""

sts
sts ">> Removing intermediate files..."
rm ca.crt ca.key ca.srl server.crt server.csr server.key

sts
sts ">> Helm command to complete installation:"
echo "helm upgrade --install --create-namespace -n $NAMESPACE --values tls-values.yaml $RELEASE $DIRNAME/chart" >&2
