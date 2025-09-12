# Cluster Toolkit deployment with Cloud Build and Docker 

### prerequisite:
- This require docker to operate for docker build and running the image.
- GCP Artifact Registry setup 
- API enablement for Cloud Build


# Cloud Build - Creating the docker image and then creating the Slurm cluster 
This method leverage Cloud build for building the environment without using any of the local environment.


There are 4 parts within the build directory:

1. **Click to Deploy** cloudbuild.yaml : This is a "click-to-deploy" example including the image building and Cluster setup all in one cloud build yaml.


Use of the command:
```bash
gcloud builds submit --project=<gcp project name> --config cloudbuild.yaml --substitutions=_GHPC_VERSION=1.64.0
```

2. **Image creation**  dockerfile and cloudbuild-image-only.yaml : This is for building the docker image for gcluster operation. 

Use of the command: 
```bash
gcloud builds submit --project=<gcp project name> --config cloudbuild-image-only.yaml --substitutions=_GHPC_VERSION=1.64.0
```

3. **Cluster Deployment** cloudbuild-deployment-only.yaml : This is for deploying the cluster. 
There are 2 files needs to be modified:
deploymentset/a3mega-slurm-deployment.yaml : This file has all the parameters required. Please make update accordingly.
deploymentset/a3mega-lustre-slurm-blueprint.yaml : This blueprint file defines the cluster. In this example, it has managed lustre with a3 mega GPUs in a slurm cluster. 

Use of the command: 
```bash
gcloud builds submit --project=<gcp project name> --timeout=7200 --config cloudbuild-deployment-only.yaml
```

4. **Destroy Cluster** cloudbuild-destroy.yaml : This is for destory the cluster.
Please update the file with the deployment name of the cluster. eg: a3mega-lustre-base

Use of the command:
```bash
gcloud builds submit --project=<gcp project name> --timeout=7200 --config cloudbuild-destroy.yaml
```

# Running on local machine - leveraging docker image only

### Running gcloud auth application-default login 
```bash
gcloud auth application-default login
```
note: please note the location of the default_credentials.json: eg: /usr/local/google/home/xxxxxx/.config/gcloud/application_default_credentials.json

### Create the docker image from the dockerfile
```bash
cd docker
sudo docker build -t gcp-hpc-tools:latest .
```

### Create the deployment folder at the host machine. 
This deployment folder is for the cluster toolkit to store the deployment directory:
```bash
mkdir deploymentfolder
```
Deployment folder is important for the cluster toolkit operation with gcluster command. Although we stored the terraform state at the GCS bucket. In order for the gcluster deploy or gcluster destroy command to work. deployment folder is needed to be retained.

### Using the docker image from the machine interactively 
Mount the application-default json, deploymentset and deploymentfolder directory:
```bash
ADC_PATH=/usr/local/google/home/xxxxx/.config/gcloud/application_default_credentials.json 
sudo docker run -it -e GOOGLE_APPLICATION_CREDENTIALS=/tmp/keys/application_default_credentials.json -v ${ADC_PATH}:/tmp/keys/application_default_credentials.json:ro -v /usr/local/google/home/thomashk/Documents/deploymentfolder:/cluster-toolkit/deploymentfolder -v /usr/local/google/home/thomashk/Documents/gcp-cluster-toolkit-deployment-test/build/deploymentset/:/cluster-toolkit/deploymentset gcp-hpc-tools /bin/sh
```
3 different parts serve from the host machine to the container:
* environment variable: GOOGLE_APPLICATION_CREDENTAILS
* deploymentset: This stores both cluster toolkit blueprint and deployment files.
* deploymentfolder: This stores the deployment directory being created / updated during the gcluster deployment process. 

## While inside the container, one can do this deployment command (Sample):
```bash
./gcluster deploy -d deploymentset/a3mega-slurm-deployment-thomashk.yaml deploymentset/a3mega-lustre-slurm-blueprint.yaml -o deploymentfolder  --auto-approve
```