#!/bin/bash
# Script to setup GKE environment for Todo App

# Set your variables (update these)
PROJECT_ID="your-gcp-project-id"
CLUSTER_NAME="todo-cluster"
CLUSTER_ZONE="us-central1-a"
REGION="us-central1"

# Make sure gcloud is configured correctly
echo "Verifying gcloud configuration..."
gcloud config set project $PROJECT_ID

# Enable required APIs
echo "Enabling required GCP APIs..."
gcloud services enable container.googleapis.com
gcloud services enable containerregistry.googleapis.com

# Create GKE cluster
echo "Creating GKE cluster (this may take a few minutes)..."
gcloud container clusters create $CLUSTER_NAME \
  --zone $CLUSTER_ZONE \
  --num-nodes=2 \
  --machine-type=e2-standard-2

# Get credentials for kubectl
echo "Getting kubectl credentials..."
gcloud container clusters get-credentials $CLUSTER_NAME --zone $CLUSTER_ZONE

# Verify cluster connection
echo "Verifying connection to cluster..."
kubectl get nodes

echo "Setup complete! Your GKE cluster is now ready."
echo "Next steps:"
echo "1. Set up GitHub Secrets for GKE_PROJECT and GKE_SA_KEY"
echo "2. Push your code to GitHub to trigger the deployment workflow" 