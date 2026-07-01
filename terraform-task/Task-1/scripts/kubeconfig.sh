#!/usr/bin/env bash
#
# Emits the connection details for a Minikube profile as JSON, for consumption
# by Terraform's `external` data source. Output keys map to the fields the
# Kubernetes provider needs.
#
# Usage: kubeconfig.sh <profile-name>
set -euo pipefail

PROFILE="${1:?profile name required}"
CONTEXT="$PROFILE"

# Pull each value straight from kubeconfig for this context/cluster/user.
# `minikube start` names the context, cluster, and user after the profile.
host=$(kubectl config view --raw -o jsonpath="{.clusters[?(@.name=='${CONTEXT}')].cluster.server}")
ca=$(kubectl config view --raw -o jsonpath="{.clusters[?(@.name=='${CONTEXT}')].cluster.certificate-authority}")
client_cert=$(kubectl config view --raw -o jsonpath="{.users[?(@.name=='${CONTEXT}')].user.client-certificate}")
client_key=$(kubectl config view --raw -o jsonpath="{.users[?(@.name=='${CONTEXT}')].user.client-key}")

# The external data source requires a flat JSON object of string values.
jq -n \
  --arg host "$host" \
  --arg ca "$ca" \
  --arg client_cert "$client_cert" \
  --arg client_key "$client_key" \
  '{host: $host, cluster_ca_certificate: $ca, client_certificate: $client_cert, client_key: $client_key}'
