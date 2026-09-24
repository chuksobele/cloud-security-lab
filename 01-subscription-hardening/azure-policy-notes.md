# Azure Policy assignments — preventive guardrails

The point of this section is the distinction between **detective** and **preventive**
control. Defender for Cloud tells you a storage account is public *after* it exists.
An Azure Policy with a `deny` effect means it never exists.

| Policy | Effect | Maps to |
|---|---|---|
| Storage accounts should prevent public blob access | Deny | CIS 3.x, MCSB DP-x |
| Secure transfer to storage accounts should be enabled | Deny | CIS 3.1 |
| Allowed locations | Deny | Data residency |
| Storage account public network access should be disabled | Audit → Deny | MCSB NS-x |
| Require `owner` tag on resources | Audit | Ownership for remediation routing |
| Management ports should be closed on virtual machines | Audit | CIS 6.x |

## Effects, in order of strength

1. **Deny** — the request fails. Strongest, and what you want for anything
   unambiguous (public storage, unencrypted resources, disallowed regions).
2. **DeployIfNotExists / Modify** — auto-remediates. Good for enabling diagnostic
   settings on every new resource without asking anyone.
3. **Audit** — reports non-compliance only. Use when a `deny` would break legitimate
   work, or while you measure impact before tightening.

## Rollout approach

Assign as `audit` first, review the compliance results for a week, then switch to
`deny` once you know what would have broken. Going straight to `deny` in a live
environment is how security teams get their policies removed.

## Equivalent in AWS

Service Control Policies do the same job at organisation scope. The concepts map
directly: SCP `Deny` ≈ Azure Policy `deny` effect; AWS Config rules with remediation
≈ `deployIfNotExists`.
