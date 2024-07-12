#!/bin/bash

# Function to print usage
usage() {
  echo "Usage: $0 <version>"
  echo "Example: $0 1.22.5"
  exit 1
}

# Check if version number is provided
if [ -z "$1" ]; then
  usage
fi

VERSION=$1
URL="https://go.dev/dl/go${VERSION}.linux-amd64.tar.gz"

# Step 1: Remove the current version of Go
echo "Removing current Go installation..."
sudo rm -rf /usr/local/go

# Step 2: Download the specified version of Go
echo "Downloading Go version ${VERSION} from ${URL}..."
wget $URL -O /tmp/go${VERSION}.linux-amd64.tar.gz

# Step 3: Extract the downloaded tarball to /usr/local
echo "Extracting Go ${VERSION} to /usr/local..."
sudo tar -C /usr/local -xzf /tmp/go${VERSION}.linux-amd64.tar.gz

# Step 4: Update PATH environment variable
echo "Updating PATH to include /usr/local/go/bin..."
if ! grep -q 'export PATH=$PATH:/usr/local/go/bin' ~/.profile; then
  echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.profile
fi
source ~/.profile

# Step 5: Verify the installation
echo "Verifying the Go installation..."
go version

echo "Go ${VERSION} has been installed successfully."