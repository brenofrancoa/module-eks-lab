#!/usr/bin/env bash
set -euo pipefail

terraform -chdir=modules/eks init -backend=false -upgrade=false
terraform -chdir=modules/eks validate
