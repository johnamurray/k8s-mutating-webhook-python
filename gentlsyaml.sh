printf "tls:\n  certificate: |\n"
sed 's/^/    /g' sidecar-webhook.pem
printf "  key: |\n"
sed 's/^/    /g' sidecar-webhook.key
printf  "  caBundle: \""
cat kube-ca.crt | tr -d '\n'
printf  "\"\n"
