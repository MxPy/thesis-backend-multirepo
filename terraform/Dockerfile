# Stage 1: Build the frontend
FROM node:latest AS frontend
WORKDIR /frontend
COPY thesis-frontend/ .
RUN npm install && npm run build

# Stage 2: Deploy with Terraform
FROM hashicorp/terraform:latest
WORKDIR /app
# Copy Terraform files
COPY terraform/*.tf .
COPY terraform/buckets-policy/ ./buckets-policy/
# Copy built frontend files from first stage
COPY --from=frontend /frontend/build/ ./build/

# Verify files and run Terraform
ENTRYPOINT ["sh", "-c", "ls -la /app/build && terraform init && terraform plan && terraform apply -auto-approve"]