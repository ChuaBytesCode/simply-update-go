#!/bin/bash

# Function to print usage
usage() {
  echo "Usage: $0 <OS> <architecture> <version>"
  echo "Example: $0 linux amd64 1.22.5"
  exit 1
}

# Function to update the script if there are updates
check_for_updates() {
  git fetch

  LOCAL=$(git rev-parse @)
  REMOTE=$(git rev-parse @{u})

  if [ $LOCAL != $REMOTE ]; then
    echo "There are updates available for this script. Do you want to update? (y/n)"
    read -r response
    if [[ "$response" == "y" || "$response" == "Y" ]]; then
      echo "Updating script..."
      git pull
      echo "Script updated. Please run the script again."
      exit 0
    else
      echo "Continuing without updating the script..."
    fi
  else
    echo "The script is up to date."
  fi
}

# Check if all arguments are provided
if [ $# -ne 3 ]; then
  usage
fi

# Assign input to variables and convert to lowercase
OS=$(echo "$1" | tr '[:upper:]' '[:lower:]')
ARCH=$(echo "$2" | tr '[:upper:]' '[:lower:]')
VERSION=$3

# Normalize OS
case $OS in
  linux|ubuntu|fedora)
    OS="linux"
    ;;
  mac|macos)
    OS="darwin"
    ;;
  *)
    echo "Unsupported OS: $OS"
    usage
    ;;
esac

# Normalize ARCH
case $ARCH in
  arm|arm64)
    ARCH="arm64"
    ;;
  amd|amd64|intel|x86|x64)
    ARCH="amd64"
    ;;
  *)
    echo "Unsupported architecture: $ARCH"
    usage
    ;;
esac

URL="https://go.dev/dl/go${VERSION}.${OS}-${ARCH}.tar.gz"

# Check for updates to the script
check_for_updates

# Step 1: Remove the current version of Go if it exists
if [ -d "/usr/local/go" ]; then
  echo "Removing current Go installation..."
  sudo rm -rf /usr/local/go
else
  echo "No existing Go installation found."
fi

# Step 2: Download the specified version of Go
echo "Downloading Go version ${VERSION} from ${URL}..."
wget $URL -O /tmp/go${VERSION}.${OS}-${ARCH}.tar.gz

# Step 3: Extract the downloaded tarball to /usr/local
echo "Extracting Go ${VERSION} to /usr/local..."
sudo tar -C /usr/local -xzf /tmp/go${VERSION}.${OS}-${ARCH}.tar.gz

# Step 4: Update PATH environment variable
echo "Updating PATH to include /usr/local/go/bin..."
PROFILE_FILE=""

if [ "$OS" = "darwin" ]; then
  if [ -f ~/.zshrc ]; then
    PROFILE_FILE=~/.zshrc
  elif [ -f ~/.bash_profile ]; then
    PROFILE_FILE=~/.bash_profile
  fi
else
  PROFILE_FILE=~/.profile
fi

if ! grep -q 'export PATH=$PATH:/usr/local/go/bin' $PROFILE_FILE; then
  echo 'export PATH=$PATH:/usr/local/go/bin' >> $PROFILE_FILE
fi
source $PROFILE_FILE

# Step 5: Verify the installation
echo "Verifying the Go installation..."
go version

echo "Go ${VERSION} has been installed successfully."
