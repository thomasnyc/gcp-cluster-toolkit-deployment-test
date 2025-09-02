# gcp-cluster-toolkit-deployment-test
Try out the docker and cloud build testing

* Run the gcloud auth login and gcloud auth application-default login 
```bash
gcloud auth application-default login
```
note: please note the location of the default_credentials.json: eg: /usr/local/google/home/xxxxxx/.config/gcloud/application_default_credentials.json

* Create the docker image from the dockerfile
```bash
cd docker
sudo docker build -t gcp-hpc-tools:latest .
```

* Create the deploymentfolder at the host machine. This deploymentfolder is for the cluster toolkit to store the deployment directory:
```bash
mkdir deploymentfolder
```

* Using the docker image from the machine interactively with the application-default json and deploymentfolder:
```bash
ADC_PATH=/usr/local/google/home/xxxxx/.config/gcloud/application_default_credentials.json 
sudo docker run -it -e GOOGLE_APPLICATION_CREDENTIALS=/tmp/keys/application_default_credentials.json -v ${ADC_PATH}:/tmp/keys/application_default_credentials.json:ro -v /usr/local/google/home/thomashk/Documents/deploymentfolder:/app/cluster-toolkit/deploymentfolder  gcp-hpc-tools /bin/sh
```

* While inside the container, one can do this deployment command (Sample):
```bash
./gcluster deploy -d deploymentset/a3mega-slurm-deployment.yaml deploymentset/a3mega-lustre-slurm-blueprint.yaml -o deploymentfolder
```



