from flask import Flask, request
from base64 import b64encode
import json, sys

server = Flask(__name__)

patch_list = "/code/conf/patchlist.json"

with open(patch_list, 'r') as patch_list_file:
    patch_list_b64 = b64encode(bytes(
        patch_list_file.read(), "utf-8")).decode('utf-8')

@server.route("/healthz")
def healthz():
    return "OK"

@server.route("/", methods=["POST"])
def hello():
    print(request.headers, file=sys.stderr)
    #print(request.data, file=sys.stderr)
    admission_review = json.loads(request.data)
    print(admission_review, file=sys.stdout)

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
    server.run(host='0.0.0.0', ssl_context=context, extra_files=[patch_list])
