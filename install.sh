#!/bin/bash
# A sample Bash script to create new venv and install Kartezio package

# Name of the venv
VENV_NAME="kartezio-env-38"

# Path to venv
VENV_PATH="./env/$VENV_NAME"

# Activate script path
ACTIVATE_SCRIPT="$VENV_PATH/bin/activate"

# Update pip manager
python3.8 -m pip install --upgrade pip

# Install virtualenv package
python3.8 -m pip install virtualenv

# Create the venv
python3.8 -m venv $VENV_PATH

# Activate the venv
source $ACTIVATE_SCRIPT

# Update pip manager for the venv
python -m pip install --upgrade pip

pip install ipykernel jupyter

cd sources/Kartezio/
python -m pip install .

python -m ipykernel install --user --name=$VENV_NAME

jupyter kernelspec list