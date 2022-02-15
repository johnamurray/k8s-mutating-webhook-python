echo ">> Creating TLS values file for Helm deployment"
echo -e "tls:\n  certificate: |"
sed 's/^/    /g' sidecar-webhook.pem
echo "  key: |"
sed 's/^/    /g' sidecar-webhook.key
echo -n "  caBundle: \""
cat kube-ca.crt | tr -d '\n'
echo "\""