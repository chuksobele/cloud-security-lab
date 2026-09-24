# 03 — Pipeline security (shift left)

Catch problems before they exist, instead of detecting them after deployment.

## What runs in CI

| Tool | Catches | Blocks build on |
|---|---|---|
| Checkov | Insecure infrastructure as code (Terraform, Bicep, Kubernetes, Dockerfile) | HIGH / CRITICAL |
| Trivy | Vulnerable OS packages and libraries in container images | CRITICAL / HIGH (fixed only) |
| Gitleaks | Secrets committed to the repo, including in git history | Any finding |

Workflow: [`.github/workflows/iac-security.yml`](../.github/workflows/iac-security.yml)

## The two Dockerfiles

`Dockerfile.insecure` and `Dockerfile.secure` build the same trivial app. The point
is the difference in scan results.

| | Insecure | Secure |
|---|---|---|
| Base image | Old full OS image | Current slim / distroless |
| Runs as | root | non-root user (UID 10001) |
| Extra packages | build tools left in | multi-stage build, none in final image |
| Secrets | API key in `ENV` | none; injected at runtime |
| Filesystem | writable | intended to run read-only |
| Healthcheck | none | present |

## Results

| Image | CRITICAL | HIGH | Total |
|---|---|---|---|
| insecure | _fill in_ | _fill in_ | _fill in_ |
| secure | _fill in_ | _fill in_ | _fill in_ |

Run locally with `scripts/scan-images.sh` and paste the real numbers.

## The point to make in an interview

You do not patch a running container. You rebuild the image and redeploy. So the
highest-leverage fix in a container estate is standardising on a small, current,
non-root base image — one change that removes hundreds of findings across every
service at once, instead of hundreds of tickets.
