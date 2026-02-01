#!/usr/bin/env bash
set -euo pipefail

terraform fmt -check
terraform init -backend=false -upgrade=false
terraform validate
