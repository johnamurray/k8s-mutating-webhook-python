from flask import Flask, request
from base64 import b64encode
import json, sys


server = Flask(__name__)

@server.route("/healthz")
def healthz():
    return "OK"

@server.route("/", methods=["POST"])
def hello():
    print(request.headers, file=sys.stderr)
    #print(request.data, file=sys.stderr)
    admission_review = json.loads(request.data)
    print(admission_review, file=sys.stdout)

    # Deployment, StatefulSet / Pod (this would capture Airflow and GitLab runner initiated Pods
    # Affinity-Preference and Toleration
    patch_list = [
      {"op": "add", "path": "/spec/tolerations/0", "value":
        {"key": "prismfp.io/environment", "operator": "Equal", "value": "upgrade-test"}
      },
    ]
    patch_list = [
      {"op": "add", "path": "/spec/tolerations/0", "value":
        {"key": "prismfp.io/role", "operator": "Equal", "value": "services"}
      },
    ]

    patch_list_b64 = b64encode(bytes(json.dumps(patch_list), "utf-8")).decode('utf-8')

    # Minimum allowed response stanza
    response = {
      "apiVersion": "admission.k8s.io/v1",
      "kind": "AdmissionReview",
      "response": {
        "uid": admission_review['request']['uid'],
        "allowed": True,
        "patchType": "JSONPatch",
        "patch": patch_list_b64
      }
    }

    return json.dumps(response)

if __name__ == "__main__":
    context = ("/certs/tls.crt", "/certs/tls.key")
    server.run(host='0.0.0.0', ssl_context=context)

