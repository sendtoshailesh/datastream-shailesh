https://cloud.google.com/community/tutorials/migrate-oracle-postgres-using-datastream



# Google Cloud project to use for this tutorial
export PROJECT_ID="[YOUR_PROJECT_ID]"

# Google Cloud region to use for Cloud SQL, Compute Engine, Datastream, and Cloud Storage bucket
export GCP_REGION_ID="[YOUR_GOOGLE_CLOUD_REGION]"

# Google Cloud zone to use for hosting the bastion Compute Engine instance
export GCP_ZONE_ID="[YOUR_GOOGLE_CLOUD_ZONE]"

# Name of the bastion VM
export BASTION_VM_NAME="[NAME_OF_BASTION_COMPUTE_ENGINE_INSTANCE]"

# Name of the Cloud Storage bucket used to host schema conversion outputs
export GCS_BUCKET="[YOUR_CLOUD_STORAGE_BUCKET]"

# Name of the Pub/Sub topic for Cloud Storage notifications
export PUBSUB_TOPIC="[YOUR_PUB_SUB_TOPIC]"

# ID of the Cloud SQL for PostgreSQL instance
export CLOUD_SQL="[CLOUD_SQL_INSTANCE_ID]"

# Target Cloud SQL for PostgreSQL version (e.g., POSTGRES_12)
export CLOUD_SQL_PG_VERSION="[CLOUD_SQL_PG_VERSION]"






# Google Cloud project to use for this tutorial
export PROJECT_ID="shailesh-1"

# Google Cloud region to use for Cloud SQL, Compute Engine, Datastream, and Cloud Storage bucket
export GCP_REGION_ID="us-central1"

# Google Cloud zone to use for hosting the bastion Compute Engine instance
export GCP_ZONE_ID="us-central1-a"

# Name of the bastion VM
export BASTION_VM_NAME="ora2pg-bastion-vm"

# Name of the Cloud Storage bucket used to host schema conversion outputs
export GCS_BUCKET="shailesh-ora2pg-datastream"

# Name of the Pub/Sub topic for Cloud Storage notifications
export PUBSUB_TOPIC="ora2pg-datastream"

# ID of the Cloud SQL for PostgreSQL instance
export CLOUD_SQL="ora2pg"

# Target Cloud SQL for PostgreSQL version (e.g., POSTGRES_12)
export CLOUD_SQL_PG_VERSION="POSTGRES_12"





# Google Cloud project to use for this tutorial
export PROJECT_ID="shailesh-1"

# Google Cloud region to use for Cloud SQL, Compute Engine, Datastream, and Cloud Storage bucket
export GCP_REGION_ID="us-central1"

# Google Cloud zone to use for hosting the bastion Compute Engine instance
export GCP_ZONE_ID="us-central1-a"


# ID of the Cloud SQL for PostgreSQL instance
export CLOUD_SQL="ora2pg"

# Version of Ora2Pg (e.g., 21.0)
export ORA2PG_VERSION="21.0"

# Version of Oracle Instant Client (e.g., 12.2)
export ORACLE_ODBC_VERSION="19.13"

# Space-separated list of Oracle schemas to export (e.g., "HR OE"). Leave blank to export all schemas.
export ORACLE_SCHEMAS="HR"

# Space-separated list of Oracle object types to export (e.g., "TABLE VIEW"). Leave blank to export all object types supported by Ora2Pg.
export ORACLE_TYPES="TABLE VIEW"


gcloud compute instances create ${BASTION_VM_NAME} \
    --zone=${GCP_ZONE_ID} \
    --boot-disk-device-name=${BASTION_VM_NAME} \
    --boot-disk-size=10GB \
    --boot-disk-type=pd-balanced \
    --subnet=subnet1 \
    --network-tier=PREMIUM \
    --image-family=debian-10 \
    --image-project=debian-cloud
    
    
    
gcloud beta sql instances create ${CLOUD_SQL} \
    --database-version=${CLOUD_SQL_PG_VERSION} \
    --cpu=4 --memory=3840MiB \
    --region=${REGION} \
    --no-assign-ip \
    --network=sh-vpc \
    --root-password=${DATABASE_PASSWORD} \
    --project=${PROJECT_ID}

SERVICE_ACCOUNT=$(gcloud sql instances describe ${CLOUD_SQL} --project=${PROJECT_ID} | grep 'serviceAccountEmailAddress' | awk '{print $2;}')

gsutil iam ch serviceAccount:${SERVICE_ACCOUNT}:objectViewer "gs://${GCS_BUCKET}"



export NEW_UUID=$(cat /proc/sys/kernel/random/uuid)
export DATAFLOW_JOB_PREFIX=ora2pg
export DATAFLOW_JOB_NAME="${DATAFLOW_JOB_PREFIX}-${NEW_UUID}"
export DATABASE_HOST=$(gcloud sql instances list --project=${PROJECT_ID} | grep "${CLOUD_SQL}" | awk '{print $2;}')
export GCS_STREAM_PATH="gs://${GCS_BUCKET}/ora2pg/"
export DATABASE_PASSWORD="<TARGET_PG_DATABASE_PASSWORD>"

gcloud beta dataflow flex-template run "${DATAFLOW_JOB_NAME}" \
    --project="${PROJECT_ID}" --region="${GCP_REGION_ID}" \
    --template-file-gcs-location="gs://dataflow-templates/latest/flex/Cloud_Datastream_to_SQL" \
    --parameters inputFilePattern="${GCS_STREAM_PATH}",\
        gcsPubSubSubscription="projects/${PROJECT_ID}/subscriptions/${PUBSUB_TOPIC}-subscription",\
        databaseHost=${DATABASE_HOST},\
        databasePort="5432",\
        databaseUser="postgres",\
        databasePassword="${DATABASE_PASSWORD}",\
        schemaMap=":",\
        maxNumWorkers=10,\
        autoscalingAlgorithm="THROUGHPUT_BASED"
        
        
export NEW_UUID=$(cat /proc/sys/kernel/random/uuid)
export DATAFLOW_JOB_PREFIX=ora2pg
export DATAFLOW_JOB_NAME="${DATAFLOW_JOB_PREFIX}-${NEW_UUID}"
export DATABASE_HOST=$(gcloud sql instances list --project=shailesh-1 | grep pg1 | awk '{print $2;}')
export GCS_STREAM_PATH="gs://shailesh-ora2pg-datastream/srcdata/"
export DATABASE_PASSWORD="Welcome0"

gcloud beta dataflow flex-template run "${DATAFLOW_JOB_NAME}" \
    --project=shailesh-1 --region=us-central1 \
    --template-file-gcs-location="gs://dataflow-templates/latest/flex/Cloud_Datastream_to_SQL" \
    --parameters inputFilePattern="${GCS_STREAM_PATH}",\
        gcsPubSubSubscription="projects/shailesh-1/subscriptions/ora2pg-datastream-subscription",\
        databaseHost=10.45.192.2,\
        databasePort="5432",\
        databaseUser="postgres",\
        databasePassword="${DATABASE_PASSWORD}"        
        
        
gcloud beta dataflow flex-template run ora2pg-372ae6af-f9ce-4792-aadc-9ff1ac0f517cs \
    --project=shailesh-1 --region=us-central1 \
    --template-file-gcs-location="gs://dataflow-templates/latest/flex/Cloud_Datastream_to_Postgres" \
    --network="sh-vpc" --subnetwork="https://www.googleapis.com/compute/v1/projects/shailesh-1/regions/us-central1/subnetworks/subnet1" \
    --parameters inputFilePattern="gs://shailesh-ora2pg-datastream/srcdata/",\
        databaseHost=10.45.192.2,\
        databasePort="5432",\
        databaseUser="postgres",\
        databasePassword=Welcome0
        
        
        
shailesh-1:us-central1:pg1        
        
        
ora2pg-372ae6af-f9ce-4792-aadc-9ff1ac0f517h
gs://shailesh-ora2pg-datastream/srcdata/
10.45.192.2
postgres
Welcome0
https://www.googleapis.com/compute/v1/projects/shailesh-1/regions/us-central1/subnetworks/subnet1



gcloud beta dataflow flex-template run ora2pg-372ae6af-f9ce-4792-aadc-9ff1ac0f517g \
    --project=shailesh-1 --region=us-central1 \
    --template-file-gcs-location="gs://dataflow-templates/latest/flex/Cloud_Datastream_to_SQL" \
    --parameters inputFilePattern="gs://shailesh-ora2pg-datastream/srcdata/",\
        databaseHost=10.45.192.2,\
        databasePort="5432",\
        databaseUser="postgres",\
        databasePassword="Welcome0"
        
        

gcloud beta dataflow flex-template run job1 \
--template-file-gcs-location gs://dataflow-templates-us-central1/latest/flex/Cloud_Datastream_to_Postgres  \
--region us-central1 \
--network="sh-vpc" --subnetwork="https://www.googleapis.com/compute/v1/projects/shailesh-1/regions/us-central1/subnetworks/subnet1" \
--parameters databaseHost=10.0.45.1,databaseUser=postgres,databasePassword=Welcome0 


gs://shailesh-ora2pg-datastrea/hrdata/

gs://shailesh-ora2pg-datastrea/hrdata/


#!/bin/bash


gcloud beta compute ssh --zone "us-central1-a" "pg-on-gce"  --tunnel-through-iap --project "shailesh-1"





gcloud services enable dataflow.googleapis.com
gcloud beta dataflow flex-template run datastream-replication \
        --project="${PROJECT_ID}" --region="us-central1" \
        --template-file-gcs-location="gs://dataflow-templates-us-central1/latest/flex/Cloud_Datastream_to_BigQuery" \
        --enable-streaming-engine \
        --parameters \
inputFilePattern="gs://${PROJECT_ID}/data/",\
gcsPubSubSubscription="projects/${PROJECT_ID}/subscriptions/datastream-subscription",\
outputProjectId="${PROJECT_ID}",\
outputStagingDatasetTemplate="dataset",\
outputDatasetTemplate="dataset",\
outputStagingTableNameTemplate="{_metadata_schema}_{_metadata_table}_log",\
outputTableNameTemplate="{_metadata_schema}_{_metadata_table}",\
deadLetterQueueDirectory="gs://${PROJECT_ID}/dlq/",\
maxNumWorkers=2,\
autoscalingAlgorithm="THROUGHPUT_BASED",\
mergeFrequencyMinutes=2,\
inputFileFormat="avro"



gcloud pubsub topics create datastream
gcloud pubsub subscriptions create datastream-subscription --topic=datastream
gsutil notification create -f "json" -p "data/" -t "datastream" "gs://shailesh-uscentral-1"

gsutil notification create -f "json" -p "data/" -t "datastream" "gs://shailesh-uscentral-1"

gsutil notification create -f "json" -t "datastream" "gs://shailesh-datastreams"

gcloud services enable dataflow.googleapis.com

export PROJECT_ID=shailesh-1

gcloud beta dataflow flex-template run datastream-replication \
        --project="${PROJECT_ID}" --region="us-central1" \
        --template-file-gcs-location="gs://dataflow-templates-us-central1/latest/flex/Cloud_Datastream_to_BigQuery" \
        --enable-streaming-engine \
        --parameters \
inputFilePattern="gs://shailesh-datastreams/",\
gcsPubSubSubscription="projects/${PROJECT_ID}/subscriptions/datastream-subscription",\
outputProjectId="${PROJECT_ID}",\
outputStagingDatasetTemplate="dataset",\
outputDatasetTemplate="dataset",\
outputStagingTableNameTemplate="{_metadata_schema}_{_metadata_table}_log",\
outputTableNameTemplate="{_metadata_schema}_{_metadata_table}",\
deadLetterQueueDirectory="gs://dataflow-staging-us-central1-664290125703/dlq/",\
maxNumWorkers=2,\
autoscalingAlgorithm="THROUGHPUT_BASED",\
mergeFrequencyMinutes=2,\
inputFileFormat="avro"


{"container_id":"21f5352320398cfc2cdd290af7e4f082a453457b7404c93f1b1d0df82c08ef8f","severity":"INFO","time":"2021/12/21 14:49:44.995612",
"line":"exec.go:38","message":"Executing: java -cp /template/datastream-to-bigquery/*:/template/datastream-to-bigquery/libs/*:/template/datastream-to-bigquery/classes com.google.cloud.teleport.v2.templates.DataStreamToBigQuery 
--region=us-central1 --outputProjectId=shailesh-1 --maxNumWorkers=2 --project=shailesh-1 --jobName=datastream-replication 
--stagingLocation=gs://dataflow-staging-us-central1-664290125703/staging 
--templateLocation=gs://dataflow-staging-us-central1-664290125703/staging/template_launches/2021-12-21_06_48_59-7063673417219263830/job_object 
--outputStagingTableNameTemplate={_metadata_schema}_{_metadata_table}_log 
--autoscalingAlgorithm=THROUGHPUT_BASED --gcsPubSubSubscription=projects/shailesh-1/subscriptions/datastream-subscription 
--enableStreamingEngine=true --inputFileFormat=avro --runner=DataflowRunner 
--labels={\n   \"goog-dataflow-provided-template-name\" : \"cloud_datastream_to_bigquery\",\n   \"goog-dataflow-provided-template-type\" : \"flex\"\n}\n 
--deadLetterQueueDirectory=gs://dataflow-staging-us-central1-664290125703/dlq/ --outputTableNameTemplate={_metadata_schema}_{_metadata_table} 
--inputFilePattern=gs://shailesh-datastreams/ --outputStagingDatasetTemplate=dataset --mergeFrequencyMinutes=2 --serviceAccount=664290125703-compute@developer.gserviceaccount.com 
--tempLocation=gs://dataflow-staging-us-central1-664290125703/tmp --outputDatasetTemplate=dataset"}



https://github.com/GoogleCloudPlatform/DataflowTemplates/tree/main/v2/datastream-to-spanner



export JOB_NAME="${IMAGE_NAME}-`date +%Y%m%d-%H%M%S-%N`"
gcloud beta dataflow flex-template run ${JOB_NAME} \
        --project=${PROJECT} --region=us-central1 \
        --template-file-gcs-location=${TEMPLATE_IMAGE_SPEC} \
        --parameters instanceId=${INSTANCE_ID},databaseId=${DATABASE_ID},inputFilePattern=${GCS_LOCATION},outputDeadletterTable=${DEADLETTER_TABLE}



datastream oracle to BQ

gcloud pubsub topics create datastream
gcloud pubsub subscriptions create datastream-subscription --topic=datastream
gsutil notification create -f "json" -p "data/" -t "datastream" "gs://shailesh-ds1"

gsutil mb gs://shailesh-ds1


export PROJECT_ID=shailesh-1

gcloud beta dataflow flex-template run datastream-replication \
        --project="${PROJECT_ID}" --region="us-central1" \
        --template-file-gcs-location="gs://dataflow-templates-us-central1/latest/flex/Cloud_Datastream_to_BigQuery" \
        --enable-streaming-engine \
        --parameters \
inputFilePattern="gs://shailesh-ds1/data/",\
gcsPubSubSubscription="projects/${PROJECT_ID}/subscriptions/datastream-subscription",\
outputProjectId="${PROJECT_ID}",\
outputStagingDatasetTemplate="dataset",\
outputDatasetTemplate="dataset",\
outputStagingTableNameTemplate="{_metadata_schema}_{_metadata_table}_log",\
outputTableNameTemplate="{_metadata_schema}_{_metadata_table}",\
deadLetterQueueDirectory="gs://dataflow-staging-us-central1-664290125703/dlq/",\
maxNumWorkers=2,\
autoscalingAlgorithm="THROUGHPUT_BASED",\
mergeFrequencyMinutes=2,\
inputFileFormat="avro"





gcloud beta dataflow flex-template run JOB_NAME \
    --project=PROJECT_ID \
    --region=REGION_NAME \
    --template-file-gcs-location=gs://dataflow-templates/VERSION/flex/Datastream_to_CloudSpanner \
    --parameters \
inputFilePattern=GCS_FILE_PATH,\
streamName=STREAM_NAME,\
instanceId=CLOUDSPANNER_INSTANCE,\
databaseId=CLOUDSPANNER_DATABASE,\
deadLetterQueueDirectory=DLQ



gcloud beta dataflow flex-template run ora2span1 \
    --project="shailesh-1" \
    --region="us-central1" \
    --template-file-gcs-location="gs://dataflow-templates/latest/flex/Cloud_Datastream_to_Spanner" \
    --parameters \
inputFilePattern="gs://shailesh-ds1/data1/",\
streamName="ora2span1",\
instanceId="quiz-instance",\
databaseId="quiz-database",\
deadLetterQueueDirectory="gs://dataflow-staging-us-central1-664290125703/dlq/"





