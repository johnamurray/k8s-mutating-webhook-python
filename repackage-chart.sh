#!/bin/bash
set -e

CHART_DIR=chart/
CHART_REPO_DIR=helm/
CHART_REPO_URL=https://raw.githubusercontent.com/ian-llewellyn/k8s-mutating-webhook-python/master/helm

helm package $CHART_DIR -d $CHART_REPO_DIR
helm repo index $CHART_REPO_DIR --url $CHART_REPO_URL
