#!/usr/bin/env bash
set -euo pipefail

terraform -chdir=modules/vpc init -backend=false -upgrade=false
terraform -chdir=modules/vpc validate
