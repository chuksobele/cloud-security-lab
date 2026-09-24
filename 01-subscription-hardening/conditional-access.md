# Conditional Access policies applied

Policies are documented here rather than exported, because CA policy JSON contains
tenant and object IDs.

## CA01 — Require MFA for administrators
- **Users:** directory roles — Global Administrator, Security Administrator,
  Privileged Role Administrator, User Administrator, Exchange Administrator
- **Exclusions:** break-glass accounts (2)
- **Cloud apps:** All
- **Grant:** Require multifactor authentication
- **Rationale:** administrative roles are the highest-value credentials in the tenant.
  CIS Azure Foundations 1.1.x; MCSB IM-4.

## CA02 — Block legacy authentication
- **Users:** All, excluding break-glass
- **Conditions:** Client apps — Exchange ActiveSync clients, Other clients
- **Grant:** Block access
- **Rationale:** legacy protocols (POP, IMAP, SMTP AUTH, older Office) do not support
  modern authentication and therefore bypass MFA entirely. This is the single most
  common route past an otherwise well-configured MFA deployment.

## CA03 — Require MFA for all users
- **Users:** All, excluding break-glass
- **Cloud apps:** All
- **Grant:** Require multifactor authentication
- **Rollout note:** deployed in report-only mode first, reviewed the impact report,
  then switched to on. Report-only mode exists precisely so you do not lock the
  tenant out — worth doing even in a lab, because it is the habit that matters.

## CA04 — Require compliant or hybrid-joined device for administrators
- **Users:** directory roles as CA01
- **Grant:** Require device to be marked as compliant OR hybrid Entra joined
- **Rationale:** raises the bar from "has the password and a token" to
  "is on a managed device". Closest Azure equivalent to conditioning on device posture.

## Break-glass account controls
- Two accounts, cloud-only, `.onmicrosoft.com` domain
- Excluded from all CA policies (otherwise a CA misconfiguration locks everyone out)
- Passwords long, random, split and stored offline
- Alert rule: any sign-in by either account raises a high-severity alert
