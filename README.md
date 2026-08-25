# environmental-app-analysis-aws-fastapi-app
Try the API deployed in AWS through swagger interface on URL: https://ens-api.navaws.ceacpoc.cloud/docs

## Local startup
uvicorn app.main:app --reload

- import variables from .env

```bash
set -o allexport && source .env.development && set +o allexport
```

## Authorize with ECR
```bash
aws ecr get-login-password --region eu-central-1 | docker login --username AWS --password-stdin 435472314818.dkr.ecr.eu-central-1.amazonaws.com
```
## Local startup in docker
1. build the image for FE and API
**API**
```bash
docker build -f ./Dockerfile-dev -t awsfastapi .
docker tag awsfastapi:latest 812222239604.dkr.ecr.eu-central-1.amazonaws.com/ens-api:<yourtag>
docker push 812222239604.dkr.ecr.eu-central-1.amazonaws.com/ens-api:<yourtag>
```

**FE**
```bash
docker build -f ./Dockerfile -t awsfastapife .
docker tag awsfastapife:latest 812222239604.dkr.ecr.eu-central-1.amazonaws.com/ens-fe:<yourtag>
docker push 812222239604.dkr.ecr.eu-central-1.amazonaws.com/ens-fe:<yourtag>
```
2. run the image, including AWS creds and mount your directory to refresh code inside container
```bash
docker run  -p 8080:80 -v ./app:/code/app --env-file=.env.development -e AWS_REGION=eu-central-1 -e AWS_ACCESS_KEY_ID="<ACCESS_ID>" -e AWS_SECRET_ACCESS_KEY="<SECRET_ACCESS_KEY>" -e AWS_SESSION_TOKEN="<SESSION_TOKEN>" -e AWS_CA_BUNDLE="" awsfastapi
```

## Execute into ECS task to debug
aws ecs execute-command  \
    --region $AWS_REGION \
    --cluster exampleproject-prod-ecs-cluster \
    --task <task_id> \
    --container exampleproject-prod-fastapi-service \
    --command "/bin/bash" \
    --interactive
