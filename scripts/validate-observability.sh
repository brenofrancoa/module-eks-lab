#!/usr/bin/env bash
set -euo pipefail

terraform -chdir=modules/observability init -backend=false -upgrade=false
terraform -chdir=modules/observability validate
