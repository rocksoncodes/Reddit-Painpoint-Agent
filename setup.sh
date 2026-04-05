#!/bin/bash
set -e

# 1. Detect OS
OS=$(uname | tr '[:upper:]' '[:lower:]')

# 2. Create virtual environment if it doesn't exist or is empty
if [ ! -d ".venv" ] || [ ! -f ".venv/bin/activate" ] && [ ! -f ".venv/Scripts/activate" ]; then
    echo "Creating virtual environment..."
    python3 -m venv .venv
else
    echo ".venv already exists. Skipping creation."
fi

# 3. Activate virtual environment
echo "Activating virtual environment..."
if [[ "$OS" == "darwin" || "$OS" == "linux" ]]; then
    source .venv/bin/activate
elif [[ "$OS" == "mingw"* || "$OS" == "cygwin"* || "$OS" == "msys"* ]]; then
    source .venv/Scripts/activate
else
    echo "Unknown OS. Please activate .venv manually."
fi

# 4. Install requirements
if [ -f "requirements.txt" ]; then
    echo "Installing packages from requirements.txt..."
    pip install -r requirements.txt
else
    echo "requirements.txt not found. Skipping package installation."
fi

# 5. Copy the example environment variable file
if [ ! -f ".env" ]; then
  echo "Setting up env template file..."
  cp .env.example .env
else
  echo ".env file already exists. Skipping .env file setup"
fi