#!/bin/bash
set -euo pipefail  # Exit script on stderr, unassigned variables, or pipe fails

### Install Terraform-Docs.

### Remove all old TFDOCS.md files and generate new TFDOCS.md files for each TF module.
# Set Modules Root Directory
#root_dir="$(Build.SourcesDirectory)"
root_dir="."

terraform-docs markdown table --output-file "${root_dir}/TFDOCS.md" --output-mode inject $root_dir

# Terraform module directory
terraformModuleDirs="${root_dir}/modules/"

# Go to terraform modules dir
cd $terraformModuleDirs

# Loop through each directory in the terraform modules directory
for dir in */; do
    #After cleanup create a new TFDOCS.md file with 'terraform-docs' based on latest TF module code in current folder(terraform module)
    tfFiles=$(find "$dir" -name "*.tf")

    printf "$tfFiles\n"

    # If tffiles exist in directory, generate TFDOCS.md file
    if [ ! -z "${tfFiles}" ]; then
        # Create new TFDOCS.md file
        terraform-docs markdown table --output-mode inject $dir --output-file "./TFDOCS.md"
    else
        echo "No .tf files found."
    fi
done

# Go back to project root dir
cd $root_dir