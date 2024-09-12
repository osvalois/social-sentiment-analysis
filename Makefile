# Makefile for Social Sentiment Analysis Project

# Variables
SHELL := /bin/bash
FRONTEND_DIR := frontend
BACKEND_DIR := backend
TERRAFORM_DIR := terraform
SCRIPTS_DIR := scripts
LAMBDA_DIR := $(BACKEND_DIR)/lambdas
DYNAMODB_PORT := 8000
S3_PORT := 9000

# Colors for output
CYAN := \033[0;36m
GREEN := \033[0;32m
YELLOW := \033[0;33m
RESET := \033[0m

# Phony targets
.PHONY: all install setup start test clean deploy help start-frontend start-backend start-lambda-tweet-collector start-lambda-sentiment-analyzer start-dynamodb start-s3 start-all

# Default target
all: install setup

# Install dependencies
install:
	@echo "$(CYAN)Installing dependencies...$(RESET)"
	@echo "Installing frontend dependencies..."
	@cd $(FRONTEND_DIR) && yarn install
	@echo "Installing backend dependencies..."
	@cd $(BACKEND_DIR) && yarn install
	@echo "Installing Lambda dependencies..."
	@cd $(LAMBDA_DIR)/tweet_collector && yarn install
	@cd $(LAMBDA_DIR)/sentiment_analyzer && pip install -r requirements.txt
	@echo "Installing global dependencies..."
	@npm install -g serverless
	@pip install awscli-local
	@$(SCRIPTS_DIR)/install-aws-cli.sh

# Setup local environment
setup:
	@echo "$(CYAN)Setting up local environment...$(RESET)"
	@if [ -f $(FRONTEND_DIR)/.env.example ]; then \
		cp $(FRONTEND_DIR)/.env.example $(FRONTEND_DIR)/.env.local; \
		echo "Frontend .env.local created. Please update with your configuration."; \
	else \
		echo "$(YELLOW)Warning: $(FRONTEND_DIR)/.env.example not found.$(RESET)"; \
	fi
	@if [ -f $(BACKEND_DIR)/.env.example ]; then \
		cp $(BACKEND_DIR)/.env.example $(BACKEND_DIR)/.env; \
		echo "Backend .env created. Please update with your configuration."; \
	else \
		echo "$(YELLOW)Warning: $(BACKEND_DIR)/.env.example not found.$(RESET)"; \
	fi
	@$(SCRIPTS_DIR)/setup-local-env.sh

# Start frontend
start-frontend:
	@echo "$(GREEN)Starting frontend...$(RESET)"
	@cd $(FRONTEND_DIR) && yarn start

# Start backend (serverless offline)
start-backend:
	@echo "$(GREEN)Starting backend (serverless offline)...$(RESET)"
	@cd $(BACKEND_DIR) && yarn run serverless offline

# Start Lambda: Tweet Collector
start-lambda-tweet-collector:
	@echo "$(GREEN)Starting Tweet Collector Lambda...$(RESET)"
	@cd $(LAMBDA_DIR)/tweet_collector && yarn run serverless offline

# Start Lambda: Sentiment Analyzer
start-lambda-sentiment-analyzer:
	@echo "$(GREEN)Starting Sentiment Analyzer Lambda...$(RESET)"
	@cd $(LAMBDA_DIR)/sentiment_analyzer && yarn run serverless offline

# Start local DynamoDB
start-dynamodb:
	@echo "$(GREEN)Starting local DynamoDB on port $(DYNAMODB_PORT)...$(RESET)"
	@docker run -p $(DYNAMODB_PORT):8000 amazon/dynamodb-local

# Start local S3 (using MinIO)
start-s3:
	@echo "$(GREEN)Starting local S3 (MinIO) on port $(S3_PORT)...$(RESET)"
	@docker run -p $(S3_PORT):9000 minio/minio server /data

# Start all components
start-all: start-dynamodb start-s3 start-backend start-lambda-tweet-collector start-lambda-sentiment-analyzer start-frontend
	@echo "$(GREEN)All components started.$(RESET)"

# Run tests
test: test-frontend test-backend

test-frontend:
	@echo "$(CYAN)Running frontend tests...$(RESET)"
	@cd $(FRONTEND_DIR) && yarn test

test-backend:
	@echo "$(CYAN)Running backend tests...$(RESET)"
	@cd $(BACKEND_DIR) && yarn test

# Clean up
clean:
	@echo "$(CYAN)Cleaning up...$(RESET)"
	@rm -rf $(FRONTEND_DIR)/node_modules
	@rm -rf $(BACKEND_DIR)/node_modules
	@rm -rf $(FRONTEND_DIR)/build
	@rm -rf $(BACKEND_DIR)/.serverless
	@rm -f $(FRONTEND_DIR)/.env.local $(BACKEND_DIR)/.env

# Deploy
deploy:
	@echo "$(CYAN)Deploying the project...$(RESET)"
	@$(SCRIPTS_DIR)/deploy.sh

# Terraform commands
terraform-init:
	@echo "$(CYAN)Initializing Terraform...$(RESET)"
	@cd $(TERRAFORM_DIR) && terraform init

terraform-plan:
	@echo "$(CYAN)Planning Terraform changes...$(RESET)"
	@cd $(TERRAFORM_DIR) && terraform plan

terraform-apply:
	@echo "$(CYAN)Applying Terraform changes...$(RESET)"
	@cd $(TERRAFORM_DIR) && terraform apply

# Help
help:
	@echo "$(CYAN)Available commands:$(RESET)"
	@echo "  make install                      - Install project dependencies"
	@echo "  make setup                        - Setup local environment"
	@echo "  make start-frontend               - Start frontend development server"
	@echo "  make start-backend                - Start backend (serverless offline)"
	@echo "  make start-lambda-tweet-collector - Start Tweet Collector Lambda"
	@echo "  make start-lambda-sentiment-analyzer - Start Sentiment Analyzer Lambda"
	@echo "  make start-dynamodb               - Start local DynamoDB"
	@echo "  make start-s3                     - Start local S3 (MinIO)"
	@echo "  make start-all                    - Start all components"
	@echo "  make test                         - Run all tests"
	@echo "  make test-frontend                - Run frontend tests"
	@echo "  make test-backend                 - Run backend tests"
	@echo "  make clean                        - Remove dependencies and build artifacts"
	@echo "  make deploy                       - Deploy the project"
	@echo "  make terraform-init               - Initialize Terraform"
	@echo "  make terraform-plan               - Plan Terraform changes"
	@echo "  make terraform-apply              - Apply Terraform changes"
	@echo "  make help                         - Show this help message"