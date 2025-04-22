# Deploying Todo App to Google Kubernetes Engine (GKE)

This guide walks you through the process of deploying the Todo application to Google Kubernetes Engine using GitHub Actions.

## Prerequisites

1. Google Cloud Platform account
2. GitHub repository with the Todo app code
3. `gcloud` CLI installed locally
4. `kubectl` installed locally

## Step 1: Set Up GKE Environment

### Option 1: Using the Setup Script

1. Update the variables in `setup-gke.sh`:
   - `PROJECT_ID`: Your Google Cloud Project ID
   - `CLUSTER_NAME`: Desired name for your GKE cluster
   - `CLUSTER_ZONE`: GCP zone for your cluster

2. Make the script executable and run it:
   ```bash
   chmod +x setup-gke.sh
   ./setup-gke.sh
   ```

### Option 2: Manual Setup

1. Enable required APIs:
   ```bash
   gcloud services enable container.googleapis.com
   gcloud services enable containerregistry.googleapis.com
   ```

2. Create a GKE cluster:
   ```bash
   gcloud container clusters create todo-cluster \
     --zone us-central1-a \
     --num-nodes=2 \
     --machine-type=e2-standard-2
   ```

3. Get credentials for kubectl:
   ```bash
   gcloud container clusters get-credentials todo-cluster --zone us-central1-a
   ```

## Step 2: Create Service Account for GitHub Actions

1. Create a service account:
   ```bash
   gcloud iam service-accounts create github-actions-sa \
     --display-name="GitHub Actions Service Account"
   ```

2. Add necessary roles to the service account:
   ```bash
   gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
     --member="serviceAccount:github-actions-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
     --role="roles/container.developer"
   
   gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
     --member="serviceAccount:github-actions-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
     --role="roles/storage.admin"
   ```

3. Create and download a key for the service account:
   ```bash
   gcloud iam service-accounts keys create gke-key.json \
     --iam-account=github-actions-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com
   ```

## Step 3: Add GitHub Secrets

1. In your GitHub repository, go to Settings > Secrets and variables > Actions
2. Add the following secrets:
   - `GKE_PROJECT`: Your Google Cloud Project ID
   - `GKE_SA_KEY`: The entire content of the `gke-key.json` file (base64 encoded)

## Step 4: Deploy Your Application

1. Push your code to the `main` branch:
   ```bash
   git push origin main
   ```

2. The GitHub Actions workflow will automatically:
   - Build the Docker image
   - Push it to Google Container Registry
   - Deploy it to your GKE cluster

3. Monitor the deployment in the GitHub Actions tab of your repository.

4. Get the external IP of your service:
   ```bash
   kubectl get service todo-app
   ```
   
5. Access your Todo app through the LoadBalancer's external IP on port 80 (http://EXTERNAL-IP)

## Adding HTTPS Later

When you're ready to add HTTPS support in the future:

1. Register a domain and set up DNS to point to your LoadBalancer IP
2. Create the necessary Kubernetes resources:
   - ManagedCertificate for automatic TLS certificate provisioning
   - Ingress resource configured to use the certificate
   - Static IP reservation

## Troubleshooting

### Common Issues:

1. **Image pull errors**: Make sure your GKE cluster has access to GCR.
2. **Auth failures**: Verify the `GKE_SA_KEY` secret is correctly formatted.
3. **Deployment failures**: Check logs with `kubectl logs deployment/todo-app`.
4. **Service not accessible**: Verify LoadBalancer has an External IP with `kubectl get svc`.

### Helpful Commands:

- Check pod status: `kubectl get pods`
- View pod logs: `kubectl logs POD_NAME`
- Check deployment: `kubectl describe deployment todo-app`
- Check service: `kubectl describe service todo-app`

## Resources

- [GKE Documentation](https://cloud.google.com/kubernetes-engine/docs)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Kubernetes Documentation](https://kubernetes.io/docs/home/) 