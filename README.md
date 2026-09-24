# cloud-security-lab

Self-directed Azure cloud security lab: subscription hardening, posture management,
misconfiguration remediation, IaC and container scanning in CI, Kubernetes policy
enforcement, and a structured security assessment report.

**Author:** Chukwuemeka David Obele — [LinkedIn](https://linkedin.com/in/chukwuemekaobele)

---

## Why this exists

I work in security operations (vulnerability management and incident response) in a
regulated financial services environment. This lab is where I build and test the
cloud-platform side of the discipline hands-on: posture management, preventive
guardrails, shift-left scanning, and workload security.

Everything here was built and run in my own Azure subscription and a local Kubernetes
cluster. Findings, scores and screenshots in `evidence/` folders are from my own runs.

## Contents

| Project | What it covers |
|---|---|
| [01 — Subscription hardening](01-subscription-hardening/) | Identity, privileged access, logging, Defender for Cloud, Azure Policy baselines |
| [02 — Misconfiguration remediation](02-misconfig-remediation/) | Deliberately insecure Terraform, detection via Defender for Cloud, remediation, secure-score delta |
| [03 — Pipeline security](03-pipeline-security/) | Checkov IaC scanning in GitHub Actions, Trivy image scanning, base-image hardening |
| [04 — Kubernetes](04-kubernetes/) | Default-deny NetworkPolicies, Pod Security Admission, kube-bench |
| [05 — Assessment report](05-assessment-report/) | Structured security assessment with prioritised findings and attack paths |

## Standards referenced

Microsoft Cloud Security Benchmark · CIS Microsoft Azure Foundations Benchmark ·
CIS Kubernetes Benchmark · NIST CSF 2.0 · CISA KEV / EPSS for prioritisation

## Cost note

Built entirely within the Azure free tier / minimal spend. A budget alert at £5 and a
teardown script are included in each project. **Run `terraform destroy` when finished.**
