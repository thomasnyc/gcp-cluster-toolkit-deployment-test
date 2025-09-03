# gcp-cluster-toolkit-deployment-test

# Prep:
This require docker to operate docker build and running the image.
You will also need to git clone this repo.

## Running gcloud auth application-default login 
```bash
gcloud auth application-default login
```
note: please note the location of the default_credentials.json: eg: /usr/local/google/home/xxxxxx/.config/gcloud/application_default_credentials.json

# * Running on local machine

## Create the docker image from the dockerfile
```bash
cd docker
sudo docker build -t gcp-hpc-tools:latest .
```

## Create the deploymentfolder at the host machine. 
This deploymentfolder is for the cluster toolkit to store the deployment directory:
```bash
mkdir deploymentfolder
```
Deployment folder is important for the cluster toolkit operation with gcluster command. Although we stored the terraform state at the GCS bucket. In order for the gcluster deploy or gcluster destroy command to work. deployment folder is needed to be retained.

## Using the docker image from the machine interactively 
Mount the application-default json, deploymentset and deploymentfolder directory:
```bash
ADC_PATH=/usr/local/google/home/xxxxx/.config/gcloud/application_default_credentials.json 
sudo docker run -it -e GOOGLE_APPLICATION_CREDENTIALS=/tmp/keys/application_default_credentials.json -v ${ADC_PATH}:/tmp/keys/application_default_credentials.json:ro -v /usr/local/google/home/thomashk/Documents/deploymentfolder:/app/cluster-toolkit/deploymentfolder -v /usr/local/google/home/thomashk/Documents/gcp-cluster-toolkit-deployment-test/build/deploymentset/:/app/cluster-toolkit/deploymentset gcp-hpc-tools /bin/sh
```
3 different parts serve from the host machine to the container:
* environment variable: GOOGLE_APPLICATION_CREDENTAILS
* deploymentset: This stores both cluster toolkit blueprint and deployment files.
* deploymentfolder: This stores the deployment directory being created / updated during the gcluster deployment process. 

## While inside the container, one can do this deployment command (Sample):
```bash
./gcluster deploy -d deploymentset/a3mega-slurm-deployment-thomashk.yaml deploymentset/a3mega-lustre-slurm-blueprint.yaml -o deploymentfolder  --auto-approve
```
# * using Cloud Build to create the docker image and store into Artifact Registry

```bash
cd build
gcloud builds submit --project=thomashk-mig --config cloudbuild-image-only.yaml --substitutions=_GHPC_VERSION=1.64.0
```

# * using Cloud Build to create the fill Cluster environment:

WIP

