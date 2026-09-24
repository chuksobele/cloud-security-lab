# 02 — Misconfiguration: introduce, detect, remediate, measure

Deliberately deploy three common Azure misconfigurations, confirm Defender for Cloud
detects them, remediate, and measure the secure-score delta.

## The three misconfigurations

| # | Misconfiguration | Real-world consequence | Defender for Cloud recommendation |
|---|---|---|---|
| 1 | Storage account allowing public blob access, HTTP permitted | Data exposure to the internet — the cause of a large share of cloud breaches | "Storage account public access should be disallowed" / "Secure transfer to storage accounts should be enabled" |
| 2 | NSG allowing 0.0.0.0/0 inbound on 22 and 3389 | Management ports exposed; brute force and a top ransomware entry route | "Management ports of virtual machines should be protected with just-in-time access" |
| 3 | Over-permissive RBAC: Owner assigned at subscription scope to a test identity | Total blast radius on compromise of one credential | "There should be more than one owner assigned to your subscription" / PIM recommendations |

## Method

1. `cd terraform/insecure && terraform init && terraform apply`
2. Wait for Defender for Cloud to assess (allow up to 24 hours; some recommendations
   refresh faster). Record the **secure score before**.
3. Screenshot the recommendations into `evidence/`.
4. `cd ../secure && terraform init && terraform apply` — same resources, hardened.
5. Record the **secure score after** and the closed recommendations.
6. `terraform destroy` in both directories.

## Note on the insecure directory

`terraform/insecure/` is excluded from Checkov in `.checkov.yaml`. That is deliberate:
its whole purpose is to be non-compliant. The exclusion is documented rather than
silent — which is the same principle as suppressing a CSPM finding with a reason and
an owner rather than just making it disappear.

## Results

| Measure | Before | After |
|---|---|---|
| Secure score | _fill in_ | _fill in_ |
| High-severity recommendations | _fill in_ | _fill in_ |
| Total recommendations | _fill in_ | _fill in_ |

## What I learned

> Fill in. Suggested prompts: how long did detection actually take? Did the secure
> score move as much as you expected? Which recommendation surprised you? What would
> you have done differently to prevent this rather than detect it?
