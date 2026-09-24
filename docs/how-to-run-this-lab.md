# How to run this lab

Order matters. Each project builds on the previous one.

## Prerequisites

| Tool | Install | Why |
|---|---|---|
| Azure subscription | Free trial or pay-as-you-go | Projects 01 and 02 |
| Azure CLI | `winget install Microsoft.AzureCLI` | Everything Azure |
| Az PowerShell | `Install-Module Az -Scope CurrentUser` | `baseline-check.ps1` |
| Terraform | `winget install HashiCorp.Terraform` | Project 02 |
| Docker Desktop | docker.com | Projects 03 and 04 |
| kind | `winget install Kubernetes.kind` | Project 04 |
| kubectl | `winget install Kubernetes.kubectl` | Project 04 |
| Trivy | trivy.dev | Project 03 |
| Checkov | `pip install checkov` | Project 03 |
| Git | git-scm.com | All |

## Cost safety, before anything else

1. Azure portal → **Cost Management** → **Budgets** → create a budget of £5 with an
   alert at 50% and 90%.
2. Use `uksouth` for everything so nothing is stranded in a region you forget about.
3. After each session: `terraform destroy` and `kind delete cluster --name seclab`.
4. Never leave a VM running overnight.

## Suggested schedule

| Session | Time | Project |
|---|---|---|
| 1 | 2 hours | 01 — subscription hardening; record the starting secure score |
| 2 | 2 hours | 02 — deploy insecure, capture findings, deploy secure, capture delta |
| 3 | 2 hours | 03 — Docker images, Trivy, Checkov, push and watch the pipeline fail then pass |
| 4 | 2 hours | 04 — Kubernetes network policy and Pod Security Admission |
| 5 | 2 hours | 05 — write the assessment report using your own evidence |

## Golden rule

Only test things you own. Everything here runs in your own subscription and your own
local cluster. Never point any of these tools at your employer's environment, a
former employer's environment, or anything on the internet you do not control.
