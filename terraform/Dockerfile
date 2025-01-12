FROM node:latest AS frontend
WORKDIR /frontend
COPY thesis-frontend/ .
RUN npm install && npm run build

FROM hashicorp/terraform:latest
WORKDIR /app
COPY terraform/*.tf .
COPY terraform/buckets-policy/ ./buckets-policy/
COPY --from=frontend /frontend/build/ ./build/

ENTRYPOINT ["sh", "-c", "terraform init && terraform plan && terraform apply -auto-approve"]