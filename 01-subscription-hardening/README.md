# 01 — Azure subscription hardening

Baseline hardening of a fresh Azure subscription, then measuring the result with
Defender for Cloud secure score.

## Objective

Take a subscription from default state to a defensible baseline across identity,
privileged access, logging and posture management — and be able to evidence each step.

## Steps

### 1. Identity and privileged access
- [ ] Enforce MFA for all administrators (Conditional Access policy — see `conditional-access.md`)
- [ ] Block legacy authentication (it bypasses MFA)
- [ ] Enable Privileged Identity Management (PIM) for Global Administrator and
      Security Administrator; make assignments **eligible**, not permanent, with
      approval and justification required
- [ ] Configure break-glass accounts: two, excluded from Conditional Access, with
      long random passwords stored offline, and an alert on any sign-in
- [ ] Review and remove standing Owner role assignments at subscription scope

### 2. Logging and monitoring
- [ ] Create a Log Analytics workspace with a defined retention period
- [ ] Stream the **Activity Log** to it via a diagnostic setting (subscription scope)
- [ ] Enable Entra ID diagnostic settings: SignInLogs, AuditLogs,
      NonInteractiveUserSignInLogs
- [ ] Set retention to meet the investigation window you would actually need

### 3. Posture management
- [ ] Enable **Microsoft Defender for Cloud** on the subscription
- [ ] Enable the **Microsoft Cloud Security Benchmark** (applied by default)
- [ ] Add the **CIS Microsoft Azure Foundations Benchmark** regulatory compliance standard
- [ ] Record the starting secure score — screenshot into `evidence/`

### 4. Preventive guardrails (Azure Policy)
- [ ] Assign a policy with `deny` effect: storage accounts must not allow public blob access
- [ ] Assign a policy with `deny` effect: storage accounts must require HTTPS (secure transfer)
- [ ] Assign a policy with `audit` effect: resources must have an `owner` tag
- [ ] Assign an initiative restricting allowed locations (data residency)
- [ ] Attempt to create a non-compliant resource and capture the denial message

### 5. Cost control
- [ ] Create a budget with an alert at £5
- [ ] Note the teardown command for every resource created

## Evidence to capture

| Evidence | File |
|---|---|
| Starting secure score | `evidence/secure-score-before.png` |
| Conditional Access policy summary | `evidence/ca-policies.png` |
| PIM eligible assignments | `evidence/pim-assignments.png` |
| Azure Policy denial message | `evidence/policy-deny.png` |
| Activity Log flowing into Log Analytics (a KQL result) | `evidence/activity-log-kql.png` |

## What I learned

> Fill this in yourself. Two or three honest observations — something that surprised
> you, something that was harder than expected, a trade-off you had to think about.
> This is the section interviewers ask about.
