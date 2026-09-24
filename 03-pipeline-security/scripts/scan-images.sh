#!/usr/bin/env bash
# Build both images and scan them with Trivy, saving output as evidence.
# Requires: docker, trivy (https://trivy.dev)
set -euo pipefail

cd "$(dirname "$0")/.."
mkdir -p evidence

for variant in insecure secure; do
  echo "=== Building lab-app:${variant} ==="
  docker build -f "Dockerfile.${variant}" -t "lab-app:${variant}" .

  echo "=== Scanning lab-app:${variant} ==="
  trivy image \
    --severity CRITICAL,HIGH,MEDIUM \
    --ignore-unfixed \
    --format table \
    "lab-app:${variant}" | tee "evidence/trivy-${variant}.txt"

  # Machine-readable copy for the summary table
  trivy image --format json --output "evidence/trivy-${variant}.json" "lab-app:${variant}"
done

echo
echo "=== Summary ==="
for variant in insecure secure; do
  crit=$(grep -c "CRITICAL" "evidence/trivy-${variant}.txt" || true)
  high=$(grep -c "HIGH" "evidence/trivy-${variant}.txt" || true)
  echo "${variant}: CRITICAL lines=${crit} HIGH lines=${high} (read the table for exact counts)"
done
echo "Paste the real counts into README.md."
