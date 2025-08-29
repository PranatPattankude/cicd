#!/bin/bash

# Variables########

REPO_URL="https://github.com/PranatPattankude/cicd.git"
echo "Enter your Docker username"
read UNAME
DOCKER_IMAGE_NAME="$UNAME/cicd_jan_16_2024"
TAG="apache2"

# variable for git repo dir
REPO_NAME=$(basename -s .git $REPO_URL)

# Check git is installed
if command -v git &> /dev/null
then
    echo "Git is already installed."
else
    echo "Git is not installed. Installing Git..."

    # Update the package list
    sudo dnf update

    # Install Git
    sudo dnf install git -y

    # Verify installation
    if command -v git &> /dev/null
    then
        echo "Git has been successfully installed."
    else
        echo "Failed to install Git."
    fi
fi

# Check if the directory exists

if [ -d "$REPO_NAME" ]; then
    while true; do
        read -p "Directory $REPO_NAME already exists. Do you want to remove it? [y/N]: " answer
        if [[ $answer =~ ^[Yy]$ ]]; then
            echo "Removing directory $REPO_NAME..."
            rm -rf "$REPO_NAME" || { echo "Failed to remove existing directory"; exit 1; }
            break
        elif [[ $answer =~ ^[Nn]$ ]]; then
            echo "Exiting without removing the directory."
            exit 0
        else
            echo "Invalid input. Please enter 'y' (yes) or 'n' (no)."
        fi
    done
fi

# Pull the latest code from the Git repository

echo "Pulling the latest code from $REPO_URL..."

git clone $REPO_URL || { echo "Failed to clone repo"; exit 1; }
echo "Opening Repo..."
cd $REPO_NAME || { echo "Failed to enter repo directory"; exit 1; }

# Check Docker is installed

if command -v docker &> /dev/null
then
    echo "Docker is already installed."
else
    echo "Docker is not installed. Installing Docker..."
        
    # Update the package list
    sudo dnf update

    # Install Docker
    sudo dnf install docker -y

    # Verify installation
    if command -v docker &> /dev/null
    then
        echo "Docker has been Successfully installed."
    else
        echo "Failed to install Docker."
    fi
fi

# Build the Docker image
echo "Building the Docker image $DOCKER_IMAGE_NAME:$TAG..."
docker build -t $DOCKER_IMAGE_NAME:$TAG . || { echo "Failed to build Docker image"; exit 1; }

# Log in to Docker Hub (you will be prompted to enter your Docker Hub credentials)
echo "Logging in to Docker Hub..."
docker login || { echo "Failed to login to Docker Hub"; exit 1; }

# Push the Docker image to Docker Hub
echo "Pushing the Docker image to Docker Hub..."
docker push $DOCKER_IMAGE_NAME:$TAG || { echo "Failed to push Docker image to Docker Hub"; exit 1; }

echo "Docker image $DOCKER_IMAGE_NAME:$TAG pushed successfully!"

# Clean up by removing the cloned repository
cd ..
rm -rf $REPO_NAME
